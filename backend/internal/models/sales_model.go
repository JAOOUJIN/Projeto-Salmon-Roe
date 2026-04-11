package models

import (
	"time"

	"go.mongodb.org/mongo-driver/bson/primitive"
)

type SalesItem struct {
	ProductID primitive.ObjectID `bson:"cd_produto" json:"cd_produto"`
	Quantity  float64            `bson:"qt_item" json:"qt_item"`
	UnitPrice float64            `bson:"vl_unitario" json:"vl_unitario"`
}

type SalesItemDTO struct {
	Product   ProductDTO `json:"cd_produto"`
	Quantity  float64    `json:"qt_item"`
	UnitPrice float64    `json:"vl_unitario"`
	ProductID string     `json:"_id"`
}

type Sales struct {
	ID         primitive.ObjectID `bson:"_id,omitempty" json:"id"`
	UserID     primitive.ObjectID `bson:"user_id" json:"user_id"`
	SalesID    int64              `bson:"cd_venda" json:"cd_venda"`
	SalesValue float64            `bson:"vl_venda" json:"sales_value"`
	Status     string             `bson:"status" json:"status"`
	Itens      []SalesItem        `bson:"itens" json:"itens"`
	CreatedAt  time.Time          `bson:"createdAt" json:"createdAt"`
	UpdatedAt  time.Time          `bson:"updatedAt" json:"updatedAt"`
	Address    string             `bson:"address" json:"address"`
	Delivery   string             `bson:"delivery" json:"delivery"`
	Payment    string             `bson:"payment" json:"payment"`
}

type SalesDTO struct {
	ID         string         `json:"_id"`
	UserID     string         `json:"user_id,omitempty"`
	SalesID    int64          `json:"cd_venda"`
	SalesValue float64        `json:"vl_venda"`
	Status     string         `json:"status"`
	Itens      []SalesItemDTO `json:"itens"`
	CreatedAt  time.Time      `json:"createdAt"`
	UpdatedAt  time.Time      `json:"updatedAt"`
	Address    string         `json:"address"`
	Delivery   string         `json:"delivery"`
	Payment    string         `json:"payment"`
}

type CreateSaleRequest struct {
	SalesID  int64                   `json:"cd_venda" binding:"required"`
	Itens    []CreateSaleItemRequest `json:"itens" binding:"required,min=1"`
	Address  string                  `json:"address"`
	Delivery string                  `json:"delivery"`
	Payment  string                  `json:"payment"`
}

type CreateSaleItemRequest struct {
	ProductID string  `json:"cd_produto" binding:"required"`
	Quantity  float64 `json:"qt_item" binding:"required,min=1"`
	UnitPrice float64 `json:"vl_unitario" binding:"required"`
}

type OrderStatusDTO struct {
	ID         string         `json:"id"`
	Status     string         `json:"status"`
	SalesValue float64        `json:"vl_venda"`
	SalesID    int64          `json:"cd_venda"`
	CreatedAt  time.Time      `json:"createdAt"`
	UpdatedAt  time.Time      `json:"updatedAt"`
	Itens      []SalesItemDTO `json:"itens"`
	Address    string         `json:"address"`
	Delivery   string         `json:"delivery"`
	Payment    string         `json:"payment"`
}
