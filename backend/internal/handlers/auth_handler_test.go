package handlers

import (
	"backend-app/internal/models"
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"testing"
	"time"

	"go.mongodb.org/mongo-driver/bson/primitive"
	"golang.org/x/crypto/bcrypt"
)

type mockAuthUserRepo struct {
	findByEmail           func(email string) (*models.CreateUser, error)
	findByPhone           func(phone string) (*models.CreateUser, error)
	create                func(user *models.CreateUser) error
	setPasswordResetToken func(ctx context.Context, userID primitive.ObjectID, codeHash string, expiresAt time.Time) error
	clearPasswordReset    func(ctx context.Context, userID primitive.ObjectID) error
	updatePasswordClear   func(ctx context.Context, userID primitive.ObjectID, passwordHash string) error
}

func (m *mockAuthUserRepo) FindByEmail(email string) (*models.CreateUser, error) {
	if m.findByEmail != nil {
		return m.findByEmail(email)
	}
	return nil, nil
}
func (m *mockAuthUserRepo) FindByPhone(phone string) (*models.CreateUser, error) {
	if m.findByPhone != nil {
		return m.findByPhone(phone)
	}
	return nil, nil
}
func (m *mockAuthUserRepo) Create(user *models.CreateUser) error {
	if m.create != nil {
		return m.create(user)
	}
	return nil
}
func (m *mockAuthUserRepo) SetPasswordResetToken(ctx context.Context, userID primitive.ObjectID, codeHash string, expiresAt time.Time) error {
	if m.setPasswordResetToken != nil {
		return m.setPasswordResetToken(ctx, userID, codeHash, expiresAt)
	}
	return nil
}
func (m *mockAuthUserRepo) ClearPasswordResetFields(ctx context.Context, userID primitive.ObjectID) error {
	if m.clearPasswordReset != nil {
		return m.clearPasswordReset(ctx, userID)
	}
	return nil
}
func (m *mockAuthUserRepo) UpdatePasswordClearReset(ctx context.Context, userID primitive.ObjectID, passwordHash string) error {
	if m.updatePasswordClear != nil {
		return m.updatePasswordClear(ctx, userID, passwordHash)
	}
	return nil
}

type mockJWT struct {
	token string
	err   error
}

func (m *mockJWT) Generate(userID, email string) (string, error) {
	if m.err != nil {
		return "", m.err
	}
	return m.token, nil
}

type mockMailer struct {
	sendErr error
	sent    int
}

func (m *mockMailer) SendPasswordResetCode(to, code string) error {
	m.sent++
	return m.sendErr
}

func TestRandomSixDigitCode(t *testing.T) {
	for range 20 {
		s, err := randomSixDigitCode()
		if err != nil {
			t.Fatal(err)
		}
		if len(s) != 6 {
			t.Fatalf("len=%d s=%q", len(s), s)
		}
		for _, r := range s {
			if r < '0' || r > '9' {
				t.Fatalf("non-digit: %q", s)
			}
		}
	}
}

func TestPasswordResetTTL_Default(t *testing.T) {
	t.Setenv("PASSWORD_RESET_CODE_TTL_MINUTES", "")
	if passwordResetTTL() != 15*time.Minute {
		t.Fatalf("%v", passwordResetTTL())
	}
}

func TestPasswordResetTTL_Custom(t *testing.T) {
	t.Setenv("PASSWORD_RESET_CODE_TTL_MINUTES", "30")
	if passwordResetTTL() != 30*time.Minute {
		t.Fatalf("%v", passwordResetTTL())
	}
}

func TestAuthHandler_Register_InvalidJSON(t *testing.T) {
	c, w := testContext(http.MethodPost, "/register", bytes.NewReader([]byte(`{`)))
	h := NewAuthHandler(&mockAuthUserRepo{}, &mockJWT{token: "t"}, nil)
	h.Register(c)
	if w.Code != http.StatusBadRequest {
		t.Fatalf("status=%d", w.Code)
	}
}

func TestAuthHandler_Register_EmailExists(t *testing.T) {
	repo := &mockAuthUserRepo{
		findByEmail: func(email string) (*models.CreateUser, error) {
			return &models.CreateUser{Email: email}, nil
		},
	}
	body := []byte(`{"email":"a@b.co","password":"secret12","phone":"11"}`)
	c, w := testContext(http.MethodPost, "/register", bytes.NewReader(body))
	NewAuthHandler(repo, &mockJWT{token: "t"}, nil).Register(c)
	if w.Code != http.StatusConflict {
		t.Fatalf("status=%d %s", w.Code, w.Body.String())
	}
}

func TestAuthHandler_Register_FindByEmailError(t *testing.T) {
	repo := &mockAuthUserRepo{
		findByEmail: func(email string) (*models.CreateUser, error) {
			return nil, errors.New("db")
		},
	}
	body := []byte(`{"email":"a@b.co","password":"secret12","phone":"11"}`)
	c, w := testContext(http.MethodPost, "/register", bytes.NewReader(body))
	NewAuthHandler(repo, &mockJWT{token: "t"}, nil).Register(c)
	if w.Code != http.StatusInternalServerError {
		t.Fatalf("status=%d", w.Code)
	}
}

func TestAuthHandler_Register_OK(t *testing.T) {
	repo := &mockAuthUserRepo{
		findByEmail: func(email string) (*models.CreateUser, error) {
			return nil, nil
		},
		create: func(user *models.CreateUser) error {
			user.ID = primitive.NewObjectID()
			return nil
		},
	}
	body := []byte(`{"email":"new@b.co","password":"secret12","phone":"119"}`)
	c, w := testContext(http.MethodPost, "/register", bytes.NewReader(body))
	NewAuthHandler(repo, &mockJWT{token: "jwt-token"}, nil).Register(c)
	if w.Code != http.StatusCreated {
		t.Fatalf("status=%d %s", w.Code, w.Body.String())
	}
	var resp map[string]any
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatal(err)
	}
	if resp["token"] != "jwt-token" {
		t.Fatalf("resp=%v", resp)
	}
}

func TestAuthHandler_Login_InvalidJSON(t *testing.T) {
	c, w := testContext(http.MethodPost, "/login", bytes.NewReader([]byte(`{`)))
	NewAuthHandler(&mockAuthUserRepo{}, &mockJWT{}, nil).Login(c)
	if w.Code != http.StatusBadRequest {
		t.Fatalf("status=%d", w.Code)
	}
}

func TestAuthHandler_Login_InvalidCredentials(t *testing.T) {
	repo := &mockAuthUserRepo{
		findByEmail: func(email string) (*models.CreateUser, error) {
			return nil, nil
		},
		findByPhone: func(phone string) (*models.CreateUser, error) {
			return nil, nil
		},
	}
	body := []byte(`{"loginId":"x@y.co","password":"any"}`)
	c, w := testContext(http.MethodPost, "/login", bytes.NewReader(body))
	NewAuthHandler(repo, &mockJWT{}, nil).Login(c)
	if w.Code != http.StatusUnauthorized {
		t.Fatalf("status=%d", w.Code)
	}
}

func TestAuthHandler_Login_OK_WithEmail(t *testing.T) {
	hash, _ := bcrypt.GenerateFromPassword([]byte("mypass"), bcrypt.MinCost)
	uid := primitive.NewObjectID()
	repo := &mockAuthUserRepo{
		findByEmail: func(email string) (*models.CreateUser, error) {
			return &models.CreateUser{ID: uid, Email: email, PasswordHash: string(hash), Name: "N"}, nil
		},
	}
	body := []byte(`{"loginId":"user@test.co","password":"mypass"}`)
	c, w := testContext(http.MethodPost, "/login", bytes.NewReader(body))
	NewAuthHandler(repo, &mockJWT{token: "tok"}, nil).Login(c)
	if w.Code != http.StatusOK {
		t.Fatalf("status=%d %s", w.Code, w.Body.String())
	}
}

func TestAuthHandler_ForgotPassword_UnknownEmailStill200(t *testing.T) {
	repo := &mockAuthUserRepo{
		findByEmail: func(email string) (*models.CreateUser, error) {
			return nil, nil
		},
	}
	body := []byte(`{"email":"nobody@test.co"}`)
	c, w := testContext(http.MethodPost, "/forgot", bytes.NewReader(body))
	NewAuthHandler(repo, &mockJWT{}, nil).ForgotPassword(c)
	if w.Code != http.StatusOK {
		t.Fatalf("status=%d", w.Code)
	}
}

func TestAuthHandler_ForgotPassword_MailerNil(t *testing.T) {
	repo := &mockAuthUserRepo{
		findByEmail: func(email string) (*models.CreateUser, error) {
			return &models.CreateUser{ID: primitive.NewObjectID(), Email: email}, nil
		},
	}
	body := []byte(`{"email":"u@test.co"}`)
	c, w := testContext(http.MethodPost, "/forgot", bytes.NewReader(body))
	NewAuthHandler(repo, &mockJWT{}, nil).ForgotPassword(c)
	if w.Code != http.StatusOK {
		t.Fatalf("status=%d", w.Code)
	}
}

func TestAuthHandler_ForgotPassword_SendFails(t *testing.T) {
	repo := &mockAuthUserRepo{
		findByEmail: func(email string) (*models.CreateUser, error) {
			return &models.CreateUser{ID: primitive.NewObjectID(), Email: email}, nil
		},
		setPasswordResetToken: func(ctx context.Context, userID primitive.ObjectID, codeHash string, expiresAt time.Time) error {
			return nil
		},
		clearPasswordReset: func(ctx context.Context, userID primitive.ObjectID) error {
			return nil
		},
	}
	m := &mockMailer{sendErr: errors.New("smtp down")}
	body := []byte(`{"email":"u@test.co"}`)
	c, w := testContext(http.MethodPost, "/forgot", bytes.NewReader(body))
	NewAuthHandler(repo, &mockJWT{}, m).ForgotPassword(c)
	if w.Code != http.StatusInternalServerError {
		t.Fatalf("status=%d", w.Code)
	}
}

func TestAuthHandler_ResetPassword_InvalidCodeFormat(t *testing.T) {
	body := []byte(`{"email":"a@b.co","otp":"abcdef","newPassword":"1234567"}`)
	c, w := testContext(http.MethodPost, "/reset", bytes.NewReader(body))
	NewAuthHandler(&mockAuthUserRepo{}, &mockJWT{}, nil).ResetPassword(c)
	if w.Code != http.StatusBadRequest {
		t.Fatalf("status=%d", w.Code)
	}
}

func TestAuthHandler_ResetPassword_NoResetFlow(t *testing.T) {
	repo := &mockAuthUserRepo{
		findByEmail: func(email string) (*models.CreateUser, error) {
			return &models.CreateUser{Email: email}, nil
		},
	}
	body := []byte(`{"email":"a@b.co","otp":"123456","newPassword":"1234567"}`)
	c, w := testContext(http.MethodPost, "/reset", bytes.NewReader(body))
	NewAuthHandler(repo, &mockJWT{}, nil).ResetPassword(c)
	if w.Code != http.StatusUnauthorized {
		t.Fatalf("status=%d", w.Code)
	}
}

func TestAuthHandler_ResetPassword_OK(t *testing.T) {
	code := "654321"
	hash, _ := bcrypt.GenerateFromPassword([]byte(code), bcrypt.MinCost)
	exp := time.Now().UTC().Add(time.Hour)
	uid := primitive.NewObjectID()
	repo := &mockAuthUserRepo{
		findByEmail: func(email string) (*models.CreateUser, error) {
			return &models.CreateUser{
				ID:                     uid,
				Email:                  email,
				PasswordResetCodeHash:  string(hash),
				PasswordResetExpiresAt: &exp,
			}, nil
		},
		updatePasswordClear: func(ctx context.Context, userID primitive.ObjectID, passwordHash string) error {
			return nil
		},
	}
	body := []byte(`{"email":"a@b.co","otp":"654321","newPassword":"newpass1"}`)
	c, w := testContext(http.MethodPost, "/reset", bytes.NewReader(body))
	NewAuthHandler(repo, &mockJWT{}, nil).ResetPassword(c)
	if w.Code != http.StatusOK {
		t.Fatalf("status=%d %s", w.Code, w.Body.String())
	}
}

func TestSixDigitCodeRe(t *testing.T) {
	if !sixDigitCodeRe.MatchString("000001") || sixDigitCodeRe.MatchString("12345a") {
		t.Fatal()
	}
}
