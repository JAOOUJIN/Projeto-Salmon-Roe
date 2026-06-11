package models

import (
	"time"

	"go.mongodb.org/mongo-driver/bson/primitive"
)

type ProductEntity struct {
	ID                 primitive.ObjectID `json:"_id,omitempty" bson:"_id,omitempty"`
	NameProduct        string             `json:"name_product" bson:"name_produto" binding:"required"`
	ProductDescription string             `json:"productDescription" bson:"ds_produto, omitempty"`
	//ProductDiscount    float64            `json:"productDiscount" bson:"product_discount"`
	ProductPrice    float64   `json:"productPrice" bson:"vl_produto" binding:"required"`
	OldProductPrice float64   `json:"oldProductPrice" bson:"vl_antigo, omitempty"`
	IsHighlighted   bool      `json:"isHighlighted" bson:"is_destaque, omitempty"`
	IsNew           bool      `json:"isNew" bson:"is_novo, omitempty"`
	Category        string    `json:"category" bson:"categoria,omitempty"`
	CreatedAt       time.Time `json:"createdAt" bson:"createdAt"`
	UpdatedAt       time.Time `json:"updatedAt" bson:"updatedAt, omitempty"`
	ProductImageUrl string    `json:"productImageUrl" bson:"image_url"`
	Active          bool      `json:"status" bson:"status_ativo, omitempty"`
}

type ProductDTO struct {
	ID                 primitive.ObjectID `json:"_id,omitempty" bson:"_id,omitempty"`
	NameProduct        string             `json:"name_produto"`
	ProductDescription string             `json:"ds_produto"`
	ProductPrice       float64            `json:"vl_produto"`
	OldProductPrice    float64            `json:"vl_antigo"`
	IsHighlighted      bool               `json:"is_destaque"`
	IsNew              bool               `json:"is_novo"`
	Category           string             `json:"categoria"`
	ProductImageUrl    string             `json:"image_url"`
	Active             bool               `json:"status_ativo"`
}

type ProdutoUpdate struct {
	ProductDescription *string  `json:"productDescription" bson:"ds_produto,omitempty"`
	ProductPrice       *float64 `json:"productPrice" bson:"vl_produto,omitempty"`
	//ProductDiscount    float64            `json:"productDiscount" bson:"product_discount"`
	//ProductImageUrl    string             `json:"productImageUrl" bson:"product_image_url"`
}

type UpdateStatusInput struct {
	Status int `json:"status"`
}
