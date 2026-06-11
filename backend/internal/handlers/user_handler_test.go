package handlers

import (
	"backend-app/internal/models"
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"golang.org/x/crypto/bcrypt"
)

const testUserObjectHex = "507f1f77bcf86cd799439011"

type mockUserRepository struct {
	addFCMToken           func(ctx context.Context, userID primitive.ObjectID, token string) error
	updateInfo            func(ctx context.Context, id bson.M, updateInfo *models.UserInfo) (*mongo.UpdateResult, error)
	updateAccess          func(ctx context.Context, id bson.M, data bson.M) (*mongo.UpdateResult, error)
	getByID               func(id primitive.ObjectID) (*models.CreateUser, error)
	addAddress            func(ctx context.Context, userID primitive.ObjectID, address *models.Address) ([]models.Address, error)
	updateAddress         func(ctx context.Context, userID primitive.ObjectID, addressID primitive.ObjectID, address *models.Address) ([]models.Address, error)
	deleteAddress         func(ctx context.Context, userID primitive.ObjectID, addressID primitive.ObjectID) ([]models.Address, error)
	getAddresses          func(ctx context.Context, userID primitive.ObjectID) ([]models.Address, *primitive.ObjectID, error)
	setDefaultAddress     func(ctx context.Context, userID primitive.ObjectID, addressID primitive.ObjectID) error
	clearDefaultAddress   func(ctx context.Context, userID primitive.ObjectID) error
	create                func(user *models.CreateUser) error
	findByEmail           func(email string) (*models.CreateUser, error)
	findByPhone           func(phone string) (*models.CreateUser, error)
	setPasswordResetToken func(ctx context.Context, userID primitive.ObjectID, codeHash string, expiresAt time.Time) error
	clearPasswordReset    func(ctx context.Context, userID primitive.ObjectID) error
	updatePasswordClear   func(ctx context.Context, userID primitive.ObjectID, passwordHash string) error
	getFCMTokens          func(ctx context.Context, userID primitive.ObjectID) ([]string, error)
}

func (m *mockUserRepository) Create(user *models.CreateUser) error {
	if m.create != nil {
		return m.create(user)
	}
	return nil
}
func (m *mockUserRepository) FindByEmail(email string) (*models.CreateUser, error) {
	if m.findByEmail != nil {
		return m.findByEmail(email)
	}
	return nil, nil
}
func (m *mockUserRepository) FindByPhone(phone string) (*models.CreateUser, error) {
	if m.findByPhone != nil {
		return m.findByPhone(phone)
	}
	return nil, nil
}
func (m *mockUserRepository) GetByID(id primitive.ObjectID) (*models.CreateUser, error) {
	if m.getByID != nil {
		return m.getByID(id)
	}
	return nil, mongo.ErrNoDocuments
}
func (m *mockUserRepository) UpdateInfo(ctx context.Context, id bson.M, updateInfo *models.UserInfo) (*mongo.UpdateResult, error) {
	if m.updateInfo != nil {
		return m.updateInfo(ctx, id, updateInfo)
	}
	return &mongo.UpdateResult{MatchedCount: 1}, nil
}
func (m *mockUserRepository) UpdateAccess(ctx context.Context, id bson.M, data bson.M) (*mongo.UpdateResult, error) {
	if m.updateAccess != nil {
		return m.updateAccess(ctx, id, data)
	}
	return &mongo.UpdateResult{}, nil
}
func (m *mockUserRepository) AddAddress(ctx context.Context, userID primitive.ObjectID, address *models.Address) ([]models.Address, error) {
	if m.addAddress != nil {
		return m.addAddress(ctx, userID, address)
	}
	return nil, nil
}
func (m *mockUserRepository) UpdateAddress(ctx context.Context, userID primitive.ObjectID, addressID primitive.ObjectID, address *models.Address) ([]models.Address, error) {
	if m.updateAddress != nil {
		return m.updateAddress(ctx, userID, addressID, address)
	}
	return nil, nil
}
func (m *mockUserRepository) DeleteAddress(ctx context.Context, userID primitive.ObjectID, addressID primitive.ObjectID) ([]models.Address, error) {
	if m.deleteAddress != nil {
		return m.deleteAddress(ctx, userID, addressID)
	}
	return nil, nil
}
func (m *mockUserRepository) GetAddresses(ctx context.Context, userID primitive.ObjectID) ([]models.Address, *primitive.ObjectID, error) {
	if m.getAddresses != nil {
		return m.getAddresses(ctx, userID)
	}
	return nil, nil, nil
}
func (m *mockUserRepository) SetDefaultAddress(ctx context.Context, userID primitive.ObjectID, addressID primitive.ObjectID) error {
	if m.setDefaultAddress != nil {
		return m.setDefaultAddress(ctx, userID, addressID)
	}
	return nil
}
func (m *mockUserRepository) ClearDefaultAddress(ctx context.Context, userID primitive.ObjectID) error {
	if m.clearDefaultAddress != nil {
		return m.clearDefaultAddress(ctx, userID)
	}
	return nil
}
func (m *mockUserRepository) SetPasswordResetToken(ctx context.Context, userID primitive.ObjectID, codeHash string, expiresAt time.Time) error {
	if m.setPasswordResetToken != nil {
		return m.setPasswordResetToken(ctx, userID, codeHash, expiresAt)
	}
	return nil
}
func (m *mockUserRepository) ClearPasswordResetFields(ctx context.Context, userID primitive.ObjectID) error {
	if m.clearPasswordReset != nil {
		return m.clearPasswordReset(ctx, userID)
	}
	return nil
}
func (m *mockUserRepository) UpdatePasswordClearReset(ctx context.Context, userID primitive.ObjectID, passwordHash string) error {
	if m.updatePasswordClear != nil {
		return m.updatePasswordClear(ctx, userID, passwordHash)
	}
	return nil
}
func (m *mockUserRepository) GetFCMTokens(ctx context.Context, userID primitive.ObjectID) ([]string, error) {
	if m.getFCMTokens != nil {
		return m.getFCMTokens(ctx, userID)
	}
	return nil, nil
}
func (m *mockUserRepository) AddFCMToken(ctx context.Context, userID primitive.ObjectID, token string) error {
	if m.addFCMToken != nil {
		return m.addFCMToken(ctx, userID, token)
	}
	return nil
}

func userCtx(t *testing.T, body []byte) (*gin.Context, *httptest.ResponseRecorder) {
	c, w := testContext(http.MethodPut, "/user", bytes.NewReader(body))
	c.Set("userId", testUserObjectHex)
	return c, w
}

func TestUserController_RegisterFCMToken_InvalidUserID(t *testing.T) {
	c, w := testContext(http.MethodPut, "/user/fcm", bytes.NewReader([]byte(`{"token":"t"}`)))
	c.Set("userId", "invalid")
	NewUserController(&mockUserRepository{}).RegisterFCMToken(c)
	if w.Code != http.StatusBadRequest {
		t.Fatalf("status=%d", w.Code)
	}
}

func TestUserController_RegisterFCMToken_InvalidJSON(t *testing.T) {
	c, w := userCtx(t, []byte(`{`))
	NewUserController(&mockUserRepository{}).RegisterFCMToken(c)
	if w.Code != http.StatusBadRequest {
		t.Fatalf("status=%d", w.Code)
	}
}

func TestUserController_RegisterFCMToken_UserNotFound(t *testing.T) {
	repo := &mockUserRepository{
		addFCMToken: func(ctx context.Context, userID primitive.ObjectID, token string) error {
			return mongo.ErrNoDocuments
		},
	}
	c, w := userCtx(t, []byte(`{"token":"abc"}`))
	NewUserController(repo).RegisterFCMToken(c)
	if w.Code != http.StatusNotFound {
		t.Fatalf("status=%d body=%s", w.Code, w.Body.String())
	}
}

func TestUserController_RegisterFCMToken_OK(t *testing.T) {
	var called bool
	repo := &mockUserRepository{
		addFCMToken: func(ctx context.Context, userID primitive.ObjectID, token string) error {
			called = true
			if token != "tok" {
				t.Fatalf("token=%q", token)
			}
			return nil
		},
	}
	c, w := userCtx(t, []byte(`{"token":"tok"}`))
	NewUserController(repo).RegisterFCMToken(c)
	if w.Code != http.StatusOK || !called {
		t.Fatalf("status=%d called=%v", w.Code, called)
	}
}

func TestUserController_UpdateInfo_NotFound(t *testing.T) {
	repo := &mockUserRepository{
		updateInfo: func(ctx context.Context, id bson.M, updateInfo *models.UserInfo) (*mongo.UpdateResult, error) {
			return &mongo.UpdateResult{MatchedCount: 0}, nil
		},
	}
	body := []byte(`{"name":"N"}`)
	c, w := userCtx(t, body)
	NewUserController(repo).UpdateInfo(c)
	if w.Code != http.StatusNotFound {
		t.Fatalf("status=%d body=%s", w.Code, w.Body.String())
	}
}

func TestUserController_UpdateInfo_OK(t *testing.T) {
	repo := &mockUserRepository{
		updateInfo: func(ctx context.Context, id bson.M, updateInfo *models.UserInfo) (*mongo.UpdateResult, error) {
			return &mongo.UpdateResult{MatchedCount: 1}, nil
		},
	}
	body := []byte(`{"name":"João"}`)
	c, w := userCtx(t, body)
	NewUserController(repo).UpdateInfo(c)
	if w.Code != http.StatusOK {
		t.Fatalf("status=%d", w.Code)
	}
}

func TestUserController_UpdateAccess_InvalidJSON(t *testing.T) {
	c, w := userCtx(t, []byte(`{`))
	NewUserController(&mockUserRepository{}).UpdateAccess(c)
	if w.Code != http.StatusBadRequest {
		t.Fatalf("status=%d", w.Code)
	}
}

func TestUserController_UpdateAccess_UserNotFound(t *testing.T) {
	repo := &mockUserRepository{
		getByID: func(id primitive.ObjectID) (*models.CreateUser, error) {
			return nil, errors.New("not found")
		},
	}
	body := []byte(`{"phone":"11999999999"}`)
	c, w := userCtx(t, body)
	NewUserController(repo).UpdateAccess(c)
	if w.Code != http.StatusNotFound {
		t.Fatalf("status=%d", w.Code)
	}
}

func TestUserController_UpdateAccess_NewPasswordWithoutCurrent(t *testing.T) {
	repo := &mockUserRepository{
		getByID: func(id primitive.ObjectID) (*models.CreateUser, error) {
			return &models.CreateUser{PasswordHash: "x"}, nil
		},
	}
	body := []byte(`{"newPassword":"secret"}`)
	c, w := userCtx(t, body)
	NewUserController(repo).UpdateAccess(c)
	if w.Code != http.StatusBadRequest {
		t.Fatalf("status=%d body=%s", w.Code, w.Body.String())
	}
}

func TestUserController_UpdateAccess_WrongCurrentPassword(t *testing.T) {
	hash, _ := bcrypt.GenerateFromPassword([]byte("oldpass"), bcrypt.MinCost)
	repo := &mockUserRepository{
		getByID: func(id primitive.ObjectID) (*models.CreateUser, error) {
			return &models.CreateUser{PasswordHash: string(hash)}, nil
		},
	}
	body := []byte(`{"currentPassword":"wrong","newPassword":"newsecret"}`)
	c, w := userCtx(t, body)
	NewUserController(repo).UpdateAccess(c)
	if w.Code != http.StatusBadRequest {
		t.Fatalf("status=%d", w.Code)
	}
}

func TestUserController_UpdateAccess_PhoneOnly_OK(t *testing.T) {
	repo := &mockUserRepository{
		getByID: func(id primitive.ObjectID) (*models.CreateUser, error) {
			return &models.CreateUser{Email: "a@b.co", Phone: "old"}, nil
		},
	}
	body := []byte(`{"phone":"11988887777"}`)
	c, w := userCtx(t, body)
	NewUserController(repo).UpdateAccess(c)
	if w.Code != http.StatusOK {
		t.Fatalf("status=%d body=%s", w.Code, w.Body.String())
	}
}

func TestUserController_RegisterAddressUser_InvalidJSON(t *testing.T) {
	c, w := userCtx(t, []byte(`{`))
	NewUserController(&mockUserRepository{}).RegisterAddressUser(c)
	if w.Code != http.StatusBadRequest {
		t.Fatalf("status=%d", w.Code)
	}
}

func TestUserController_RegisterAddressUser_OK(t *testing.T) {
	addrID := primitive.NewObjectID()
	repo := &mockUserRepository{
		addAddress: func(ctx context.Context, userID primitive.ObjectID, address *models.Address) ([]models.Address, error) {
			return []models.Address{{ID: addrID, Street: "Rua A"}}, nil
		},
	}
	body := []byte(`{"street":"Rua A","number":"1","city":"SP","state":"SP","zip":"01000-000"}`)
	c, w := userCtx(t, body)
	NewUserController(repo).RegisterAddressUser(c)
	if w.Code != http.StatusCreated {
		t.Fatalf("status=%d %s", w.Code, w.Body.String())
	}
}

func TestUserController_GetAllAddressUser_NoContentMongo(t *testing.T) {
	repo := &mockUserRepository{
		getAddresses: func(ctx context.Context, userID primitive.ObjectID) ([]models.Address, *primitive.ObjectID, error) {
			return nil, nil, errors.New("mongo: no documents in result")
		},
	}
	c, w := userCtx(t, nil)
	c.Request.Method = http.MethodGet
	c.Request.Body = http.NoBody
	NewUserController(repo).GetAllAddressUser(c)
	if w.Code != http.StatusNoContent {
		t.Fatalf("status=%d", w.Code)
	}
}

func TestUserController_GetAllAddressUser_OK(t *testing.T) {
	aid := primitive.NewObjectID()
	repo := &mockUserRepository{
		getAddresses: func(ctx context.Context, userID primitive.ObjectID) ([]models.Address, *primitive.ObjectID, error) {
			return []models.Address{{ID: aid}}, &aid, nil
		},
	}
	c, w := userCtx(t, nil)
	c.Request.Method = http.MethodGet
	c.Request.Body = http.NoBody
	NewUserController(repo).GetAllAddressUser(c)
	if w.Code != http.StatusOK {
		t.Fatalf("status=%d", w.Code)
	}
	var resp map[string]any
	_ = json.Unmarshal(w.Body.Bytes(), &resp)
	if resp["defaultAddressId"] != aid.Hex() {
		t.Fatalf("resp=%v", resp)
	}
}

func TestUserController_SetDefaultAddress_InvalidAddressID(t *testing.T) {
	c, w := userCtx(t, nil)
	c.Request.Method = http.MethodPut
	c.Params = gin.Params{{Key: "address-id", Value: "bad"}}
	NewUserController(&mockUserRepository{}).RegisterAddressDefaultUser(c)
	if w.Code != http.StatusBadRequest {
		t.Fatalf("status=%d", w.Code)
	}
}

func TestGetUserID(t *testing.T) {
	c, _ := testContext(http.MethodGet, "/", nil)
	c.Set("userId", testUserObjectHex)
	if GetUserID(c) != testUserObjectHex {
		t.Fatal()
	}
}
