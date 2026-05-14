package handlers

import (
	"backend-app/internal/models"
	"backend-app/internal/utils"
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"sync"
	"testing"
	"time"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

type mockSalesRepository struct {
	create           func(ctx context.Context, sale *models.Sales) error
	findAll          func(ctx context.Context) ([]models.Sales, error)
	findByID         func(ctx context.Context, id primitive.ObjectID) (*models.Sales, error)
	findByUserID     func(ctx context.Context, userID primitive.ObjectID) ([]models.Sales, error)
	findLastByUserID func(ctx context.Context, userID primitive.ObjectID) (*models.Sales, error)
	updateStatus     func(ctx context.Context, id primitive.ObjectID, status string) (*models.Sales, error)
}

func (m *mockSalesRepository) Create(ctx context.Context, sale *models.Sales) error {
	if m.create != nil {
		return m.create(ctx, sale)
	}
	return nil
}
func (m *mockSalesRepository) FindAll(ctx context.Context) ([]models.Sales, error) {
	if m.findAll != nil {
		return m.findAll(ctx)
	}
	return nil, nil
}
func (m *mockSalesRepository) FindByID(ctx context.Context, id primitive.ObjectID) (*models.Sales, error) {
	if m.findByID != nil {
		return m.findByID(ctx, id)
	}
	return nil, nil
}
func (m *mockSalesRepository) FindByUserID(ctx context.Context, userID primitive.ObjectID) ([]models.Sales, error) {
	if m.findByUserID != nil {
		return m.findByUserID(ctx, userID)
	}
	return nil, nil
}
func (m *mockSalesRepository) FindLastByUserID(ctx context.Context, userID primitive.ObjectID) (*models.Sales, error) {
	if m.findLastByUserID != nil {
		return m.findLastByUserID(ctx, userID)
	}
	return nil, nil
}
func (m *mockSalesRepository) UpdateStatus(ctx context.Context, id primitive.ObjectID, status string) (*models.Sales, error) {
	if m.updateStatus != nil {
		return m.updateStatus(ctx, id, status)
	}
	return nil, nil
}

type mockProductRepoSales struct {
	findByID func(ctx context.Context, id interface{}) (*models.ProductEntity, error)
}

func (m *mockProductRepoSales) FindAll(ctx context.Context) ([]models.ProductEntity, error) {
	return nil, nil
}
func (m *mockProductRepoSales) FindByName(ctx context.Context, name string) ([]models.ProductEntity, error) {
	return nil, nil
}
func (m *mockProductRepoSales) FindByID(ctx context.Context, id interface{}) (*models.ProductEntity, error) {
	if m.findByID != nil {
		return m.findByID(ctx, id)
	}
	return nil, nil
}

type spyNotifier struct {
	mu    sync.Mutex
	calls int
}

func (s *spyNotifier) NotifyOrderStatus(ctx context.Context, userID primitive.ObjectID, saleMongoID primitive.ObjectID, salesCD int64, status string) {
	s.mu.Lock()
	s.calls++
	s.mu.Unlock()
}

func salesCtrl(sales *mockSalesRepository, prod *mockProductRepoSales, user *mockUserRepository, n *spyNotifier) *SalesController {
	return NewSalesController(sales, prod, user, n)
}

func TestSalesController_CreateSale_InvalidJSON(t *testing.T) {
	c, w := testContext(http.MethodPost, "/sales", bytes.NewReader([]byte(`{`)))
	c.Set("userId", testUserObjectHex)
	t.Setenv("MP_ACCESS_TOKEN", "")
	salesCtrl(&mockSalesRepository{}, &mockProductRepoSales{}, &mockUserRepository{}, nil).CreateSale(c)
	if w.Code != http.StatusBadRequest {
		t.Fatalf("status=%d", w.Code)
	}
}

func TestSalesController_CreateSale_InvalidProductID(t *testing.T) {
	body := []byte(`{"cd_venda":1,"itens":[{"cd_produto":"bad","qt_item":1,"vl_unitario":1}]}`)
	c, w := testContext(http.MethodPost, "/sales", bytes.NewReader(body))
	c.Set("userId", testUserObjectHex)
	salesCtrl(&mockSalesRepository{}, &mockProductRepoSales{}, &mockUserRepository{}, nil).CreateSale(c)
	if w.Code != http.StatusBadRequest {
		t.Fatalf("status=%d %s", w.Code, w.Body.String())
	}
}

func TestSalesController_CreateSale_ProductNotFound(t *testing.T) {
	pid := primitive.NewObjectID().Hex()
	body := []byte(`{"cd_venda":1,"itens":[{"cd_produto":"` + pid + `","qt_item":1,"vl_unitario":10}]}`)
	c, w := testContext(http.MethodPost, "/sales", bytes.NewReader(body))
	c.Set("userId", testUserObjectHex)
	prod := &mockProductRepoSales{
		findByID: func(ctx context.Context, id interface{}) (*models.ProductEntity, error) {
			return nil, nil
		},
	}
	salesCtrl(&mockSalesRepository{}, prod, &mockUserRepository{}, nil).CreateSale(c)
	if w.Code != http.StatusBadRequest {
		t.Fatalf("status=%d %s", w.Code, w.Body.String())
	}
}

func TestSalesController_CreateSale_UserNotFound(t *testing.T) {
	pid := primitive.NewObjectID()
	body := []byte(`{"cd_venda":1,"itens":[{"cd_produto":"` + pid.Hex() + `","qt_item":1,"vl_unitario":10}]}`)
	c, w := testContext(http.MethodPost, "/sales", bytes.NewReader(body))
	c.Set("userId", testUserObjectHex)
	prod := &mockProductRepoSales{
		findByID: func(ctx context.Context, id interface{}) (*models.ProductEntity, error) {
			return &models.ProductEntity{ID: pid, ProductPrice: 5}, nil
		},
	}
	salesCtrl(&mockSalesRepository{}, prod, &mockUserRepository{}, nil).CreateSale(c)
	if w.Code != http.StatusNotFound {
		t.Fatalf("status=%d %s", w.Code, w.Body.String())
	}
}

func TestSalesController_CreateSale_MissingMPToken(t *testing.T) {
	pid := primitive.NewObjectID()
	body := []byte(`
	{"cd_venda":1,
	"itens":[
	{
	"cd_produto":"` + pid.Hex() + `",
	"qt_item":1,"vl_unitario":10}
	],
	"payment": "Pix"
	}
`)
	c, w := testContext(http.MethodPost, "/sales", bytes.NewReader(body))
	c.Set("userId", testUserObjectHex)
	t.Setenv("MP_ACCESS_TOKEN", "")
	prod := &mockProductRepoSales{
		findByID: func(ctx context.Context, id interface{}) (*models.ProductEntity, error) {
			return &models.ProductEntity{ID: pid, ProductPrice: 5}, nil
		},
	}
	user := &mockUserRepository{
		getByID: func(id primitive.ObjectID) (*models.CreateUser, error) {
			return &models.CreateUser{Email: "buyer@test.co"}, nil
		},
	}
	sales := &mockSalesRepository{
		create: func(ctx context.Context, sale *models.Sales) error {
			sale.ID = primitive.NewObjectID()
			return nil
		},
	}
	salesCtrl(sales, prod, user, nil).CreateSale(c)
	if w.Code != http.StatusInternalServerError {
		t.Fatalf("status=%d %s", w.Code, w.Body.String())
	}
}

func TestSalesController_GetSales_DBError(t *testing.T) {
	s := &mockSalesRepository{
		findAll: func(ctx context.Context) ([]models.Sales, error) {
			return nil, errors.New("db")
		},
	}
	c, w := testContext(http.MethodGet, "/sales", nil)
	salesCtrl(s, &mockProductRepoSales{}, &mockUserRepository{}, nil).GetSales(c)
	if w.Code != http.StatusBadRequest {
		t.Fatalf("status=%d", w.Code)
	}
}

func TestSalesController_GetSales_Empty(t *testing.T) {
	s := &mockSalesRepository{
		findAll: func(ctx context.Context) ([]models.Sales, error) {
			return []models.Sales{}, nil
		},
	}
	c, w := testContext(http.MethodGet, "/sales", nil)
	salesCtrl(s, &mockProductRepoSales{}, &mockUserRepository{}, nil).GetSales(c)
	if w.Code != http.StatusNoContent {
		t.Fatalf("status=%d", w.Code)
	}
}

func TestSalesController_GetSaleById_InvalidID(t *testing.T) {
	c, w := testContext(http.MethodGet, "/sales/x", nil)
	c.Params = gin.Params{{Key: "id", Value: "nope"}}
	salesCtrl(&mockSalesRepository{}, &mockProductRepoSales{}, &mockUserRepository{}, nil).GetSaleById(c)
	if w.Code != http.StatusBadRequest {
		t.Fatalf("status=%d", w.Code)
	}
}

func TestSalesController_GetSaleById_NotFound(t *testing.T) {
	id := primitive.NewObjectID()
	s := &mockSalesRepository{
		findByID: func(ctx context.Context, oid primitive.ObjectID) (*models.Sales, error) {
			return nil, nil
		},
	}
	c, w := testContext(http.MethodGet, "/sales/"+id.Hex(), nil)
	c.Params = gin.Params{{Key: "id", Value: id.Hex()}}
	salesCtrl(s, &mockProductRepoSales{}, &mockUserRepository{}, nil).GetSaleById(c)
	if w.Code != http.StatusNotFound {
		t.Fatalf("status=%d", w.Code)
	}
}

func TestSalesController_GetUserSales_Unauthorized(t *testing.T) {
	c, w := testContext(http.MethodGet, "/sales/my", nil)
	salesCtrl(&mockSalesRepository{}, &mockProductRepoSales{}, &mockUserRepository{}, nil).GetUserSales(c)
	if w.Code != http.StatusUnauthorized {
		t.Fatalf("status=%d", w.Code)
	}
}

func TestSalesController_GetUserSales_OK(t *testing.T) {
	sid := primitive.NewObjectID()
	pid := primitive.NewObjectID()
	s := &mockSalesRepository{
		findByUserID: func(ctx context.Context, userID primitive.ObjectID) ([]models.Sales, error) {
			return []models.Sales{{
				ID:      sid,
				UserID:  userID,
				SalesID: 1,
				Status:  utils.StatusPending,
				Itens: []models.SalesItem{{
					ProductID: pid,
					Quantity:  1,
					UnitPrice: 10,
				}},
			}}, nil
		},
	}
	prod := &mockProductRepoSales{
		findByID: func(ctx context.Context, id interface{}) (*models.ProductEntity, error) {
			return &models.ProductEntity{ID: pid, NameProduct: "P"}, nil
		},
	}
	c, w := testContext(http.MethodGet, "/sales/my", nil)
	c.Set("userId", testUserObjectHex)
	salesCtrl(s, prod, &mockUserRepository{}, nil).GetUserSales(c)
	if w.Code != http.StatusOK {
		t.Fatalf("status=%d %s", w.Code, w.Body.String())
	}
}

func TestSalesController_GetLastOrderStatus_NotFound(t *testing.T) {
	s := &mockSalesRepository{
		findLastByUserID: func(ctx context.Context, userID primitive.ObjectID) (*models.Sales, error) {
			return nil, nil
		},
	}
	c, w := testContext(http.MethodGet, "/sales/last", nil)
	c.Set("userId", testUserObjectHex)
	salesCtrl(s, &mockProductRepoSales{}, &mockUserRepository{}, nil).GetLastOrderStatus(c)
	if w.Code != http.StatusNotFound {
		t.Fatalf("status=%d", w.Code)
	}
}

func TestSalesController_UpdateSaleStatus_ForbiddenWhenSecretSet(t *testing.T) {
	t.Setenv("ORDER_STATUS_UPDATE_SECRET", "s3cr3t")
	t.Cleanup(func() { t.Setenv("ORDER_STATUS_UPDATE_SECRET", "") })
	id := primitive.NewObjectID()
	body := []byte(`{"status":"` + utils.StatusConfirmed + `"}`)
	c, w := testContext(http.MethodPut, "/sales/"+id.Hex()+"/status", bytes.NewReader(body))
	c.Params = gin.Params{{Key: "id", Value: id.Hex()}}
	salesCtrl(&mockSalesRepository{}, &mockProductRepoSales{}, &mockUserRepository{}, nil).UpdateSaleStatus(c)
	if w.Code != http.StatusForbidden {
		t.Fatalf("status=%d", w.Code)
	}
}

func TestSalesController_UpdateSaleStatus_InvalidStatus(t *testing.T) {
	id := primitive.NewObjectID()
	body := []byte(`{"status":"invalid_status_xyz"}`)
	c, w := testContext(http.MethodPut, "/sales/"+id.Hex()+"/status", bytes.NewReader(body))
	c.Params = gin.Params{{Key: "id", Value: id.Hex()}}
	c.Request.Header.Set("X-Order-Status-Secret", "s3cr3t")
	t.Setenv("ORDER_STATUS_UPDATE_SECRET", "s3cr3t")
	t.Cleanup(func() { t.Setenv("ORDER_STATUS_UPDATE_SECRET", "") })
	salesCtrl(&mockSalesRepository{}, &mockProductRepoSales{}, &mockUserRepository{}, nil).UpdateSaleStatus(c)
	if w.Code != http.StatusBadRequest {
		t.Fatalf("status=%d %s", w.Code, w.Body.String())
	}
}

func TestSalesController_UpdateSaleStatus_OK_Notifies(t *testing.T) {
	t.Setenv("ORDER_STATUS_UPDATE_SECRET", "")
	id := primitive.NewObjectID()
	uid := primitive.NewObjectID()
	body := []byte(`{"status":"` + utils.StatusShipped + `"}`)
	s := &mockSalesRepository{
		updateStatus: func(ctx context.Context, oid primitive.ObjectID, status string) (*models.Sales, error) {
			return &models.Sales{
				ID:        oid,
				UserID:    uid,
				SalesID:   99,
				Status:    status,
				UpdatedAt: time.Now().UTC(),
				CreatedAt: time.Now().UTC(),
			}, nil
		},
	}
	spy := &spyNotifier{}
	c, w := testContext(http.MethodPut, "/sales/"+id.Hex()+"/status", bytes.NewReader(body))
	c.Params = gin.Params{{Key: "id", Value: id.Hex()}}
	salesCtrl(s, &mockProductRepoSales{}, &mockUserRepository{}, spy).UpdateSaleStatus(c)
	if w.Code != http.StatusOK {
		t.Fatalf("status=%d %s", w.Code, w.Body.String())
	}
	var resp map[string]any
	_ = json.Unmarshal(w.Body.Bytes(), &resp)
	if resp["message"] != "Status atualizado" {
		t.Fatalf("resp=%v", resp)
	}
	spy.mu.Lock()
	n := spy.calls
	spy.mu.Unlock()
	if n != 1 {
		t.Fatalf("notifier calls=%d", n)
	}
}

func TestSalesController_populateProducts_MissingProduct(t *testing.T) {
	sid := primitive.NewObjectID()
	pid := primitive.NewObjectID()
	sale := models.Sales{
		ID:     sid,
		Itens:  []models.SalesItem{{ProductID: pid, Quantity: 1, UnitPrice: 3}},
		Status: utils.StatusPending,
	}
	prod := &mockProductRepoSales{
		findByID: func(ctx context.Context, id interface{}) (*models.ProductEntity, error) {
			return nil, nil
		},
	}
	c, _ := testContext(http.MethodGet, "/", nil)
	dto := salesCtrl(&mockSalesRepository{}, prod, &mockUserRepository{}, nil).populateProducts(c, sale)
	if len(dto.Itens) != 1 || dto.Itens[0].ProductID != pid.Hex() {
		t.Fatalf("dto=%+v", dto)
	}
}
