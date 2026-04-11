package handlers

import (
	"backend-app/internal/errors"
	"backend-app/internal/models"
	repo "backend-app/internal/repositories"
	"backend-app/internal/utils"
	"context"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"golang.org/x/crypto/bcrypt"
)

type UserController struct {
	repo repo.UserRepositoryInterface
}

type UserControllerInterface interface {
	GetUsersRoutes(rGroup *gin.RouterGroup)
}

func NewUserController(service repo.UserRepositoryInterface) *UserController {
	return &UserController{service}
}

func (p *UserController) GetUsersRoutes(routerGroup *gin.RouterGroup) {
	routerGroup.PUT(utils.UserUpdateAccessURL, p.UpdateAccess)
	routerGroup.PUT(utils.UserUpdateInfoURL, p.UpdateInfo)
	// Address routes
	routerGroup.GET(utils.AddressGroup, p.GetAllAddressUser)
	routerGroup.POST(utils.AddressRegisterURL, p.RegisterAddressUser)
	routerGroup.PUT(utils.AddressUpdateURL, p.UpdateAddressUser)
	routerGroup.DELETE(utils.AddressDeleteURL, p.DeleteAddressUser)
	routerGroup.PUT(utils.AddressRegisterDefaultURL, p.RegisterAddressDefaultUser)
}

func (p *UserController) UpdateInfo(c *gin.Context) {
	log := utils.LoggerFromContext(c.Request.Context())

	objID, err := primitive.ObjectIDFromHex(GetUserID(c))
	if err != nil {
		c.JSON(http.StatusBadRequest, errors.ErrInvalidParams)
	}
	var user models.UserInfo

	if err := c.ShouldBindJSON(&user); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	user.UpdatedAt = time.Now()
	ctx, _ := context.WithTimeout(context.Background(), 5*time.Second)

	filter := bson.M{"_id": objID}

	log.Debug("atualizando informacoes de usuarios", utils.Function, utils.FnCallerName())
	result, errDB := p.repo.UpdateInfo(ctx, filter, &user)

	if errDB != nil || result.MatchedCount == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Usuario não encontrado"})
		return
	}
	c.JSON(http.StatusOK, user)
}

func (p *UserController) UpdateAccess(c *gin.Context) {
	var userAccess models.UserAccess
	if err := c.ShouldBindJSON(&userAccess); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Dados inválidos"})
		return
	}

	objID, _ := primitive.ObjectIDFromHex(GetUserID(c))

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	// 2. Buscar usuário no Banco
	user, err := p.repo.GetByID(objID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Usuário não encontrado"})
		return
	}

	// Preparar as atualizações
	updateData := bson.M{}

	// 3. Lógica do Telefone
	if userAccess.Phone != utils.EmptyString {
		updateData["phone"] = userAccess.Phone
	}

	// 4. Lógica de Senha
	if userAccess.PasswordHashNew != utils.EmptyString {
		if userAccess.PasswordHash == utils.EmptyString {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Senha atual é obrigatória"})
			return
		}

		// Comparar senha atual (hash vs texto plano)
		err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(userAccess.PasswordHash))
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Senha atual incorreta"})
			return
		}

		// Gerar Hash da nova senha
		hashedPassword, _ := bcrypt.GenerateFromPassword([]byte(userAccess.PasswordHashNew), bcrypt.DefaultCost)
		updateData["password"] = string(hashedPassword)
	}

	// 5. Executar o Update se houver algo para atualizar
	if len(updateData) > 0 {
		updateData["updatedAt"] = time.Now()
		_, err := p.repo.UpdateAccess(ctx, bson.M{"_id": objID}, bson.M{"$set": updateData})
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Erro ao atualizar banco"})
			return
		}

		if userAccess.Phone != "" {
			user.Phone = userAccess.Phone
		}

	}

	c.JSON(http.StatusOK, user)
}

func (p *UserController) RegisterAddressDefaultUser(c *gin.Context) {
	objID, err := primitive.ObjectIDFromHex(GetUserID(c))
	if err != nil {
		c.JSON(http.StatusBadRequest, errors.ErrInvalidParams)
		return
	}
	addrIDHex := c.Param("address-id")
	addrID, err := primitive.ObjectIDFromHex(addrIDHex)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID de endereço inválido"})
		return
	}
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := p.repo.SetDefaultAddress(ctx, objID, addrID); err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Endereço não encontrado para este usuário"})
		return
	}
	reponse := models.UserDTO{
		DefaultAddressID: &addrID,
	}
	c.JSON(http.StatusOK, reponse)
}

func (p *UserController) RegisterAddressUser(c *gin.Context) {
	objID, err := primitive.ObjectIDFromHex(GetUserID(c))

	if err != nil {
		c.JSON(http.StatusBadRequest, errors.ErrInvalidParams)
		return
	}

	var address models.Address

	if err := c.ShouldBindJSON(&address); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Dados de endereço inválidos"})
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)

	defer cancel()

	created, err := p.repo.AddAddress(ctx, objID, &address)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Falha ao cadastrar endereço"})
		return
	}
	c.JSON(http.StatusCreated, gin.H{
		"addresses": created,
	})
}

func (p *UserController) UpdateAddressUser(c *gin.Context) {
	objID, err := primitive.ObjectIDFromHex(GetUserID(c))
	if err != nil {
		c.JSON(http.StatusBadRequest, errors.ErrInvalidParams)
		return
	}

	addrIDHex := c.Param("address-id")

	addrID, err := primitive.ObjectIDFromHex(addrIDHex)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID de endereço inválido"})
		return
	}
	var address models.Address
	if err := c.ShouldBindJSON(&address); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Dados de endereço inválidos"})
		return
	}
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	resultAddress, err := p.repo.UpdateAddress(ctx, objID, addrID, &address)

	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Endereço não encontrado"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Endereço atualizado com sucesso", "addresses": resultAddress})
}

func (p *UserController) DeleteAddressUser(c *gin.Context) {
	objID, err := primitive.ObjectIDFromHex(GetUserID(c))
	if err != nil {
		c.JSON(http.StatusBadRequest, errors.ErrInvalidParams)
		return
	}
	addrIDHex := c.Param("address-id")
	addrID, err := primitive.ObjectIDFromHex(addrIDHex)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID de endereço inválido"})
		return
	}
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	// If deleting default address, clear it
	_, defaultID, _ := p.repo.GetAddresses(ctx, objID)
	if defaultID != nil && defaultID.Hex() == addrID.Hex() {
		_ = p.repo.ClearDefaultAddress(ctx, objID)
	}

	result, err := p.repo.DeleteAddress(ctx, objID, addrID)

	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Endereço não encontrado"})
		return
	}
	c.JSON(http.StatusOK, gin.H{
		"addresses": result,
	})
}

func (p *UserController) GetAllAddressUser(c *gin.Context) {
	objID, err := primitive.ObjectIDFromHex(GetUserID(c))
	if err != nil {
		c.JSON(http.StatusBadRequest, errors.ErrInvalidParams)
		return
	}
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	addresses, defaultID, err := p.repo.GetAddresses(ctx, objID)
	if err != nil {
		if err.Error() == "mongo: no documents in result" {
			c.JSON(http.StatusNoContent, ":nenhum endereco cadastrado!")
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erro ao buscar endereços"})
		return
	}
	resp := gin.H{
		"addresses": addresses,
	}
	if defaultID != nil {
		resp["defaultAddressId"] = defaultID.Hex()
	}
	c.JSON(http.StatusOK, resp)
}

func GetUserID(c *gin.Context) string {
	id, _ := c.Get("userId")
	return id.(string)
}
