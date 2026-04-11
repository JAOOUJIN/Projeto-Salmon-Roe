package models

import "go.mongodb.org/mongo-driver/bson/primitive"

type Address struct {
	ID           primitive.ObjectID `bson:"_id,omitempty" json:"id"`
	Street       string             `bson:"street,omitempty" json:"street,omitempty"`
	Number       string             `bson:"number,omitempty" json:"number,omitempty"`
	City         string             `bson:"city,omitempty" json:"city,omitempty"`
	State        string             `bson:"state,omitempty" json:"state,omitempty"`
	Zip          string             `bson:"zip,omitempty" json:"zip,omitempty"`
	Complement   string             `bson:"complement,omitempty" json:"complement,omitempty"`
	Neighborhood string             `bson:"neighborhood,omitempty" json:"neighborhood,omitempty"`
}
