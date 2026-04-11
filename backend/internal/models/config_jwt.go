package models

import "time"

type ConfigJWT struct {
	JWTSecret    string
	JWTExpiresIn time.Duration
}

type RegisterRequest struct {
	Email        string    `bson:"email" json:"email"`
	Phone        string    `bson:"phone" json:"phone"`
	PasswordHash string    `bson:"password" json:"password"`
	CreatedAt    time.Time `bson:"createdAt" json:"createdAt"`
	UpdatedAt    time.Time `bson:"updatedAt" json:"updatedAt"`
}

type LoginRequest struct {
	Email    string `json:"loginId" binding:"required,email"`
	Password string `json:"password" binding:"required"`
}

type ForgotPasswordRequest struct {
	Email string `json:"email" binding:"required,email"`
}

type ResetPasswordRequest struct {
	Email       string `json:"email" binding:"required,email"`
	Code        string `json:"otp" binding:"required,len=6"`
	NewPassword string `json:"newPassword" binding:"required,min=6"`
}
