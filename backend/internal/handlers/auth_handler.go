package handlers

import (
	"backend-app/internal/models"
	"backend-app/internal/services/mail"
	util "backend-app/internal/utils"
	"context"
	"crypto/rand"
	"fmt"
	"log/slog"
	"math/big"
	"net/http"
	"os"
	"regexp"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"golang.org/x/crypto/bcrypt"
)

// authUserRepository restringe o repositório ao que o fluxo de autenticação precisa (facilita testes com mock).
type authUserRepository interface {
	FindByEmail(email string) (*models.CreateUser, error)
	FindByPhone(phone string) (*models.CreateUser, error)
	Create(user *models.CreateUser) error
	SetPasswordResetToken(ctx context.Context, userID primitive.ObjectID, codeHash string, expiresAt time.Time) error
	ClearPasswordResetFields(ctx context.Context, userID primitive.ObjectID) error
	UpdatePasswordClearReset(ctx context.Context, userID primitive.ObjectID, passwordHash string) error
}

type jwtTokenGenerator interface {
	Generate(userID, email string) (string, error)
}

type AuthHandler struct {
	repo       authUserRepository
	jwtManager jwtTokenGenerator
	mailer     mail.PasswordResetMailer
}

func NewAuthHandler(repo authUserRepository, jwtManager jwtTokenGenerator, mailer mail.PasswordResetMailer) *AuthHandler {
	return &AuthHandler{
		repo:       repo,
		jwtManager: jwtManager,
		mailer:     mailer,
	}
}

type AuthHandlerInterface interface {
	Register(c *gin.Context)
	Login(c *gin.Context)
}

func (h *AuthHandler) GetDashboardRoutes(rGroup *gin.RouterGroup) {
	rGroup.POST(util.UserRegisterURL, h.Register)
	rGroup.POST(util.LoginURL, h.Login)
	rGroup.POST(util.ForgotPasswordURL, h.ForgotPassword)
	rGroup.POST(util.ResetPasswordURL, h.ResetPassword)
}

var sixDigitCodeRe = regexp.MustCompile(`^[0-9]{6}$`)

func randomSixDigitCode() (string, error) {
	n, err := rand.Int(rand.Reader, big.NewInt(1_000_000))
	if err != nil {
		return "", err
	}
	return fmt.Sprintf("%06d", n.Int64()), nil
}

func passwordResetTTL() time.Duration {
	m, err := strconv.Atoi(os.Getenv("PASSWORD_RESET_CODE_TTL_MINUTES"))
	if err != nil || m < 1 {
		m = 15
	}
	return time.Duration(m) * time.Minute
}

func (h *AuthHandler) Register(c *gin.Context) {
	var req models.RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{util.ErrorLabel: "payload inválido"})
		return
	}

	existing, err := h.repo.FindByEmail(req.Email)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{util.ErrorLabel: "erro ao verificar usuário"})
		return
	}
	if existing != nil {
		c.JSON(http.StatusConflict, gin.H{util.ErrorLabel: "email já cadastrado"})
		return
	}

	pwHash, err := bcrypt.GenerateFromPassword([]byte(req.PasswordHash), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{util.ErrorLabel: "erro ao processar senha"})
		return
	}

	user := &models.CreateUser{
		Email:        req.Email,
		PasswordHash: string(pwHash),
		Phone:        req.Phone,
	}
	if err := h.repo.Create(user); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{util.ErrorLabel: "erro ao criar usuário"})
		return
	}

	token, err := h.jwtManager.Generate(user.ID.Hex(), user.Email)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{util.ErrorLabel: "erro ao gerar token"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"user": gin.H{
			"id":    user.ID.Hex(),
			"email": user.Email,
		},
		"token": token,
	})
}

func (h *AuthHandler) Login(c *gin.Context) {
	var req models.LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{util.ErrorLabel: "payload inválido"})
		return
	}

	user, err := h.repo.FindByEmail(req.Email)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{util.ErrorLabel: "erro ao buscar usuário"})
		return
	}

	if user == nil {
		user, err = h.repo.FindByPhone(req.Email)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{util.ErrorLabel: "erro ao buscar usuário"})
			return
		}
	}

	if user == nil {
		c.JSON(http.StatusUnauthorized, gin.H{util.ErrorLabel: "credenciais inválidas"})
		return
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(req.Password)); err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{util.ErrorLabel: "credenciais inválidas"})
		return
	}

	token, err := h.jwtManager.Generate(user.ID.Hex(), user.Email)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{util.ErrorLabel: "erro ao gerar token"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"user": gin.H{
			"id":    user.ID.Hex(),
			"name":  user.Name,
			"email": user.Email,
			"phone": user.Phone,
			"cpf":   user.CPF,
		},
		"token": token,
	})
}

func (h *AuthHandler) ForgotPassword(c *gin.Context) {
	var req models.ForgotPasswordRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{util.ErrorLabel: "payload inválido"})
		return
	}

	user, err := h.repo.FindByEmail(req.Email)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{util.ErrorLabel: "erro ao processar solicitação"})
		return
	}
	if user == nil {
		c.JSON(http.StatusOK, gin.H{"message": util.ForgotPasswordOkMsg})
		return
	}

	if h.mailer == nil {
		slog.Error("recuperação de senha: Resend não configurado (defina RESEND_API_KEY e RESEND_FROM)")
		c.JSON(http.StatusOK, gin.H{"message": util.ForgotPasswordOkMsg})
		return
	}

	code, err := randomSixDigitCode()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{util.ErrorLabel: "erro ao gerar código"})
		return
	}

	codeHash, err := bcrypt.GenerateFromPassword([]byte(code), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{util.ErrorLabel: "erro ao processar código"})
		return
	}

	expires := time.Now().UTC().Add(passwordResetTTL())
	if err := h.repo.SetPasswordResetToken(context.Background(), user.ID, string(codeHash), expires); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{util.ErrorLabel: "erro ao salvar solicitação"})
		return
	}

	if err := h.mailer.SendPasswordResetCode(user.Email, code); err != nil {
		slog.Error("falha ao enviar e-mail de recuperação", "err", err)
		_ = h.repo.ClearPasswordResetFields(context.Background(), user.ID)
		c.JSON(http.StatusInternalServerError, gin.H{util.ErrorLabel: "não foi possível enviar o e-mail. Tente novamente."})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": util.ForgotPasswordOkMsg})
}

func (h *AuthHandler) ResetPassword(c *gin.Context) {
	var req models.ResetPasswordRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{util.ErrorLabel: "payload inválido"})
		return
	}
	if !sixDigitCodeRe.MatchString(req.Code) {
		c.JSON(http.StatusBadRequest, gin.H{util.ErrorLabel: "código deve ter 6 dígitos numéricos"})
		return
	}

	user, err := h.repo.FindByEmail(req.Email)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{util.ErrorLabel: "erro ao buscar usuário"})
		return
	}
	if user == nil || user.PasswordResetCodeHash == "" || user.PasswordResetExpiresAt == nil {
		c.JSON(http.StatusUnauthorized, gin.H{util.ErrorLabel: util.ErrCodeInvalidOrExpir})
		return
	}
	if time.Now().UTC().After(*user.PasswordResetExpiresAt) {
		c.JSON(http.StatusUnauthorized, gin.H{util.ErrorLabel: util.ErrCodeInvalidOrExpir})
		return
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordResetCodeHash), []byte(req.Code)); err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{util.ErrorLabel: util.ErrCodeInvalidOrExpir})
		return
	}

	pwHash, err := bcrypt.GenerateFromPassword([]byte(req.NewPassword), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{util.ErrorLabel: "erro ao processar nova senha"})
		return
	}

	if err := h.repo.UpdatePasswordClearReset(context.Background(), user.ID, string(pwHash)); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{util.ErrorLabel: "erro ao atualizar senha"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "senha alterada com sucesso"})
}
