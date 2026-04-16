package repositories

import (
	db "backend-app/internal/config/database"
	"backend-app/internal/models"
	"backend-app/internal/utils"
	"context"
	"errors"
	"time"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

type SalesRepository struct {
	collection *mongo.Collection
}

type SalesRepositoryInterface interface {
	Create(ctx context.Context, sale *models.Sales) error
	FindAll(ctx context.Context) ([]models.Sales, error)
	FindByID(ctx context.Context, id primitive.ObjectID) (*models.Sales, error)
	FindByUserID(ctx context.Context, userID primitive.ObjectID) ([]models.Sales, error)
	FindLastByUserID(ctx context.Context, userID primitive.ObjectID) (*models.Sales, error)
	UpdateStatus(ctx context.Context, id primitive.ObjectID, status string) (*models.Sales, error)
}

func NewSalesRepository(collectionName string) SalesRepositoryInterface {
	return &SalesRepository{
		collection: db.GetCollection(collectionName),
	}
}

func (s *SalesRepository) Create(ctx context.Context, sale *models.Sales) error {
	ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	now := time.Now().UTC()
	sale.ID = primitive.NilObjectID
	sale.CreatedAt = now
	sale.UpdatedAt = now
	if sale.Status == utils.EmptyString {
		sale.Status = utils.StatusPending
	}

	res, err := s.collection.InsertOne(ctx, sale)
	if err != nil {
		return err
	}

	oid, ok := res.InsertedID.(primitive.ObjectID)
	if ok {
		sale.ID = oid
	}
	return nil
}

func (s *SalesRepository) FindAll(ctx context.Context) ([]models.Sales, error) {
	ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()

	cursor, err := s.collection.Find(ctx, bson.M{}, options.Find().SetSort(bson.M{"createdAt": -1}))
	if err != nil {
		return nil, err
	}
	defer func(cursor *mongo.Cursor, ctx context.Context) {
		err = cursor.Close(ctx)
		if err != nil {
			// Log error but don't panic
		}
	}(cursor, ctx)

	var sales []models.Sales
	if err = cursor.All(ctx, &sales); err != nil {
		return nil, err
	}
	return sales, nil
}

func (s *SalesRepository) FindByID(ctx context.Context, id primitive.ObjectID) (*models.Sales, error) {
	ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()

	var sale models.Sales
	err := s.collection.FindOne(ctx, bson.M{"_id": id}).Decode(&sale)
	if err != nil {
		if errors.Is(err, mongo.ErrNoDocuments) {
			return nil, nil
		}
		return nil, err
	}
	return &sale, nil
}

func (s *SalesRepository) FindByUserID(ctx context.Context, userID primitive.ObjectID) ([]models.Sales, error) {
	ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()

	cursor, err := s.collection.Find(ctx, bson.M{"user_id": userID}, options.Find().SetSort(bson.M{"createdAt": -1}))
	if err != nil {
		return nil, err
	}
	defer func(cursor *mongo.Cursor, ctx context.Context) {
		err = cursor.Close(ctx)
		if err != nil {
			// Log error but don't panic
		}
	}(cursor, ctx)

	var sales []models.Sales
	if err = cursor.All(ctx, &sales); err != nil {
		return nil, err
	}
	return sales, nil
}

func (s *SalesRepository) FindLastByUserID(ctx context.Context, userID primitive.ObjectID) (*models.Sales, error) {
	ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()

	var sale models.Sales
	opts := options.FindOne().
		SetSort(bson.M{"createdAt": -1}) // Ordena por data de criação descendente (mais recente primeiro)

	err := s.collection.FindOne(ctx, bson.M{"user_id": userID}, opts).Decode(&sale)
	if err != nil {
		if errors.Is(err, mongo.ErrNoDocuments) {
			return nil, nil
		}
		return nil, err
	}
	return &sale, nil
}

func (s *SalesRepository) UpdateStatus(ctx context.Context, id primitive.ObjectID, status string) (*models.Sales, error) {
	ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()

	now := time.Now().UTC()
	filter := bson.M{"_id": id}
	update := bson.M{"$set": bson.M{"status": status, "updatedAt": now}}
	opts := options.FindOneAndUpdate().SetReturnDocument(options.After)

	var sale models.Sales
	err := s.collection.FindOneAndUpdate(ctx, filter, update, opts).Decode(&sale)
	if err != nil {
		if errors.Is(err, mongo.ErrNoDocuments) {
			return nil, nil
		}
		return nil, err
	}
	return &sale, nil
}
