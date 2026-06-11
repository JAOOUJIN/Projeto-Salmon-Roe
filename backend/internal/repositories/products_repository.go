package repositories

import (
	db "backend-app/internal/config/database"
	"backend-app/internal/models"
	"context"
	"fmt"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

type ProductRepository struct {
	collection *mongo.Collection
}

type ProductRepositoryInterface interface {
	FindAll(ctx context.Context) ([]models.ProductEntity, error)
	FindByName(ctx context.Context, name string) ([]models.ProductEntity, error)
	FindByID(ctx context.Context, id interface{}) (*models.ProductEntity, error)
}

func NewProductRepository(collectionName string) ProductRepositoryInterface {
	return &ProductRepository{
		collection: db.GetCollection(collectionName),
	}
}

func (p *ProductRepository) FindAll(ctx context.Context) ([]models.ProductEntity, error) {
	filter := bson.M{"status_ativo": true}
	cursor, err := p.collection.Find(ctx, filter, options.Find())
	if err != nil {
		return nil, err
	}

	defer func(cursor *mongo.Cursor, ctx context.Context) {
		err = cursor.Close(ctx)
		if err != nil {
			panic(err)
		}
	}(cursor, ctx)

	var products []models.ProductEntity

	if err = cursor.All(ctx, &products); err != nil {
		return nil, err
	}

	fmt.Printf("%+v\n", products)
	return products, nil
}

func (p *ProductRepository) FindByName(ctx context.Context, name string) ([]models.ProductEntity, error) {
	// Busca produtos por nome usando regex case-insensitive
	filter := bson.M{
		"status_ativo": true,
		"name_produto": bson.M{
			"$regex":   name,
			"$options": "i",
		},
	}

	cursor, err := p.collection.Find(ctx, filter, options.Find())
	if err != nil {
		return nil, err
	}
	defer func(cursor *mongo.Cursor, ctx context.Context) {
		err = cursor.Close(ctx)
		if err != nil {
			panic(err)
		}
	}(cursor, ctx)

	var products []models.ProductEntity
	if err = cursor.All(ctx, &products); err != nil {
		return nil, err
	}
	return products, nil
}

func (p *ProductRepository) FindByID(ctx context.Context, id interface{}) (*models.ProductEntity, error) {
	var product models.ProductEntity
	err := p.collection.FindOne(ctx, bson.M{"_id": id}).Decode(&product)
	if err != nil {
		return nil, err
	}
	return &product, nil
}
