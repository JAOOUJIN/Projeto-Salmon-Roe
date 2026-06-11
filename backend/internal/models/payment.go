package models

type PixRequest struct {
	Title      string  `json:"title" binding:"required"`
	Amount     float64 `json:"amount" binding:"required,gt=0"`
	PayerEmail string  `json:"payer_email" binding:"required,email"`
}
