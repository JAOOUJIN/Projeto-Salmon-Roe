package handlers

import (
	erro "backend-app/internal/errors"
	"backend-app/internal/models"
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"testing"

	"go.mongodb.org/mongo-driver/bson/primitive"
)

type mockProductRepo struct {
	findAll   func(ctx context.Context) ([]models.ProductEntity, error)
	findByName func(ctx context.Context, name string) ([]models.ProductEntity, error)
	findByID  func(ctx context.Context, id interface{}) (*models.ProductEntity, error)
}

func (m *mockProductRepo) FindAll(ctx context.Context) ([]models.ProductEntity, error) {
	if m.findAll != nil {
		return m.findAll(ctx)
	}
	return nil, nil
}

func (m *mockProductRepo) FindByName(ctx context.Context, name string) ([]models.ProductEntity, error) {
	if m.findByName != nil {
		return m.findByName(ctx, name)
	}
	return nil, nil
}

func (m *mockProductRepo) FindByID(ctx context.Context, id interface{}) (*models.ProductEntity, error) {
	if m.findByID != nil {
		return m.findByID(ctx, id)
	}
	return nil, nil
}

func TestProductController_GetAllProducts_DBError(t *testing.T) {
	repo := &mockProductRepo{
		findAll: func(ctx context.Context) ([]models.ProductEntity, error) {
			return nil, errors.New("db down")
		},
	}
	c, w := testContext(http.MethodGet, "/products", nil)
	NewProductController(repo).GetAllProducts(c)
	if w.Code != http.StatusBadRequest {
		t.Fatalf("status=%d body=%s", w.Code, w.Body.String())
	}
	var got erro.ApiError
	if err := json.Unmarshal(w.Body.Bytes(), &got); err != nil {
		t.Fatal(err)
	}
	if got.Error != erro.ErrInternalServer.Error() {
		t.Fatalf("erro inesperado: %q", got.Error)
	}
}

func TestProductController_GetAllProducts_Empty(t *testing.T) {
	repo := &mockProductRepo{
		findAll: func(ctx context.Context) ([]models.ProductEntity, error) {
			return []models.ProductEntity{}, nil
		},
	}
	c, w := testContext(http.MethodGet, "/products", nil)
	NewProductController(repo).GetAllProducts(c)
	if w.Code != http.StatusNoContent {
		t.Fatalf("status=%d", w.Code)
	}
}

func TestProductController_GetAllProducts_OK(t *testing.T) {
	id := primitive.NewObjectID()
	repo := &mockProductRepo{
		findAll: func(ctx context.Context) ([]models.ProductEntity, error) {
			return []models.ProductEntity{{
				ID:                 id,
				NameProduct:        "Ikura",
				ProductDescription: "desc",
				ProductPrice:       10.5,
				ProductImageUrl:    "u",
			}}, nil
		},
	}
	c, w := testContext(http.MethodGet, "/products", nil)
	NewProductController(repo).GetAllProducts(c)
	if w.Code != http.StatusOK {
		t.Fatalf("status=%d body=%s", w.Code, w.Body.String())
	}
	var got []models.ProductDTO
	if err := json.Unmarshal(w.Body.Bytes(), &got); err != nil {
		t.Fatal(err)
	}
	if len(got) != 1 || got[0].NameProduct != "Ikura" {
		t.Fatalf("dto=%+v", got)
	}
}

func TestProductController_GetProductByName_MissingName(t *testing.T) {
	c, w := testContext(http.MethodGet, "/products/search", nil)
	NewProductController(&mockProductRepo{}).GetProductByName(c)
	if w.Code != http.StatusBadRequest {
		t.Fatalf("status=%d", w.Code)
	}
}

func TestProductController_GetProductByName_OK(t *testing.T) {
	id := primitive.NewObjectID()
	repo := &mockProductRepo{
		findByName: func(ctx context.Context, name string) ([]models.ProductEntity, error) {
			if name != "roe" {
				t.Fatalf("name=%q", name)
			}
			return []models.ProductEntity{{ID: id, NameProduct: "roe", ProductPrice: 1}}, nil
		},
	}
	c, w := testContext(http.MethodGet, "/products/search?name=roe", nil)
	NewProductController(repo).GetProductByName(c)
	if w.Code != http.StatusOK {
		t.Fatalf("status=%d", w.Code)
	}
}

func TestToDTO(t *testing.T) {
	id := primitive.NewObjectID()
	out := ToDTO([]models.ProductEntity{{ID: id, NameProduct: "A", ProductPrice: 2}})
	if len(out) != 1 || out[0].NameProduct != "A" {
		t.Fatalf("%+v", out)
	}
}

func TestToDTO_Empty(t *testing.T) {
	if len(ToDTO(nil)) != 0 {
		t.Fatal()
	}
}
