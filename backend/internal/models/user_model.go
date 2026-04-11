package models

import (
	"time"

	"go.mongodb.org/mongo-driver/bson/primitive"
)

type (
	CreateUser struct {
		ID                     primitive.ObjectID `bson:"_id,omitempty" json:"id"`
		Name                   string             `bson:"name" json:"name"`
		Email                  string             `bson:"email" json:"email"`
		PasswordHash           string             `bson:"password,omitempty" json:"-"`
		CreatedAt              time.Time          `bson:"createdAt" json:"createdAt"`
		Phone                  string             `bson:"phone" json:"phone"`
		CPF                    string             `bson:"cpf,omitempty" json:"cpf,omitempty"`
		PasswordResetCodeHash  string             `bson:"passwordResetCodeHash,omitempty" json:"-"`
		PasswordResetExpiresAt *time.Time         `bson:"passwordResetExpiresAt,omitempty" json:"-"`
	}

	UserEntity struct {
		ID               primitive.ObjectID  `bson:"_id,omitempty" json:"id"`
		Email            string              `bson:"email" json:"email"`
		Password         string              `bson:"password" json:"password"`
		Phone            string              `bson:"phone,omitempty" json:"phone,omitempty"`
		Name             string              `bson:"name,omitempty" json:"name,omitempty"`
		CPF              string              `bson:"cpf,omitempty" json:"cpf,omitempty"`
		Addresses        []Address           `bson:"addresses" json:"addresses"`
		DefaultAddressID *primitive.ObjectID `bson:"defaultAddressId,omitempty" json:"defaultAddressId,omitempty"`
	}

	UserDTO struct {
		ID               primitive.ObjectID  `bson:"_id,omitempty" json:"id"`
		Email            string              `bson:"email" json:"email"`
		Password         string              `bson:"password" json:"password"`
		Phone            string              `bson:"phone,omitempty" json:"phone,omitempty"`
		Name             string              `bson:"name,omitempty" json:"name,omitempty"`
		CPF              string              `bson:"cpf,omitempty" json:"cpf,omitempty"`
		Addresses        []Address           `bson:"addresses" json:"addresses"`
		DefaultAddressID *primitive.ObjectID `bson:"defaultAddressId,omitempty" json:"defaultAddressId,omitempty"`
	}
	UserInfo struct {
		//ID   primitive.ObjectID `bson:"_id,omitempty" json:"id"`
		Name      string    `bson:"name,omitempty" json:"name,omitempty"`
		CPF       string    `bson:"cpf,omitempty" json:"cpf,omitempty"`
		UpdatedAt time.Time `json:"updatedAt" bson:"updatedAt, omitempty"`
	}
	UserAccess struct {
		ID              primitive.ObjectID `bson:"_id,omitempty" json:"id"`
		Phone           string             `bson:"phone,omitempty" json:"phone,omitempty"`
		PasswordHash    string             `bson:"password,omitempty" json:"currentPassword"`
		PasswordHashNew string             `bson:"password,omitempty" json:"newPassword"`
		UpdatedAt       time.Time          `json:"-" bson:"updatedAt, omitempty"`
	}
)

type (
	AddressesListEntity struct {
		Addresses        []Address           `bson:"addresses" json:"addresses"`
		DefaultAddressID *primitive.ObjectID `bson:"defaultAddressId,omitempty"`
	}
)
