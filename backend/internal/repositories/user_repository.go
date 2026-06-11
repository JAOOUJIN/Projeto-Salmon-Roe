package repositories

import (
	db "backend-app/internal/config/database"
	"backend-app/internal/models"
	"context"
	"errors"
	"fmt"
	"time"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

type UserRepository struct {
	coll *mongo.Collection
}

type UserRepositoryInterface interface {
	Create(user *models.CreateUser) error
	FindByEmail(email string) (*models.CreateUser, error)
	FindByPhone(phone string) (*models.CreateUser, error)
	GetByID(id primitive.ObjectID) (*models.CreateUser, error)
	UpdateInfo(c context.Context, id bson.M, updateInfo *models.UserInfo) (*mongo.UpdateResult, error)
	UpdateAccess(c context.Context, id bson.M, data bson.M) (*mongo.UpdateResult, error)
	// Address operations
	AddAddress(ctx context.Context, userID primitive.ObjectID, address *models.Address) ([]models.Address, error)
	UpdateAddress(ctx context.Context, userID primitive.ObjectID, addressID primitive.ObjectID, address *models.Address) ([]models.Address, error)
	DeleteAddress(ctx context.Context, userID primitive.ObjectID, addressID primitive.ObjectID) ([]models.Address, error)
	GetAddresses(ctx context.Context, userID primitive.ObjectID) ([]models.Address, *primitive.ObjectID, error)
	SetDefaultAddress(ctx context.Context, userID primitive.ObjectID, addressID primitive.ObjectID) error
	ClearDefaultAddress(ctx context.Context, userID primitive.ObjectID) error
	SetPasswordResetToken(ctx context.Context, userID primitive.ObjectID, codeHash string, expiresAt time.Time) error
	ClearPasswordResetFields(ctx context.Context, userID primitive.ObjectID) error
	UpdatePasswordClearReset(ctx context.Context, userID primitive.ObjectID, passwordHash string) error
	GetFCMTokens(ctx context.Context, userID primitive.ObjectID) ([]string, error)
	AddFCMToken(ctx context.Context, userID primitive.ObjectID, token string) error
}

func NewUserRepository(dbName string) *UserRepository {
	return &UserRepository{
		coll: db.GetCollection(dbName),
	}
}

func (r *UserRepository) Create(user *models.CreateUser) error {
	user.ID = primitive.NilObjectID
	user.CreatedAt = time.Now().UTC()
	res, err := r.coll.InsertOne(db.Ctx(), user)
	if err != nil {
		return err
	}
	oid, ok := res.InsertedID.(primitive.ObjectID)
	if ok {
		user.ID = oid
	}
	return nil
}

func (r *UserRepository) FindByEmail(email string) (*models.CreateUser, error) {
	var u models.CreateUser
	err := r.coll.FindOne(db.Ctx(), bson.M{"email": email}).Decode(&u)
	if err != nil {
		if errors.Is(err, mongo.ErrNoDocuments) {
			return nil, nil
		}
		return nil, err
	}
	return &u, nil
}

func (r *UserRepository) FindByPhone(phone string) (*models.CreateUser, error) {
	var u models.CreateUser
	err := r.coll.FindOne(db.Ctx(), bson.M{"phone": phone}).Decode(&u)
	if err != nil {
		if errors.Is(err, mongo.ErrNoDocuments) {
			return nil, nil
		}
		return nil, err
	}
	return &u, nil
}

func (r *UserRepository) GetByID(id primitive.ObjectID) (*models.CreateUser, error) {
	var u models.CreateUser
	err := r.coll.FindOne(db.Ctx(), bson.M{"_id": id}).Decode(&u)
	if err != nil {
		return nil, err
	}
	return &u, nil
}

func (r *UserRepository) UpdateInfo(c context.Context, id bson.M, updateInfo *models.UserInfo) (*mongo.UpdateResult, error) {
	ctx, cancel := context.WithTimeout(c, 5*time.Second)
	defer cancel()

	update := bson.M{"$set": updateInfo}

	result, err := r.coll.UpdateOne(ctx, id, update)
	if err != nil {
		return nil, fmt.Errorf("falha ao atualizar info de usuario: %w", err)
	}
	return result, nil
}

func (r *UserRepository) UpdateAccess(c context.Context, id bson.M, data bson.M) (*mongo.UpdateResult, error) {
	ctx, cancel := context.WithTimeout(c, 5*time.Second)
	defer cancel()

	result, err := r.coll.UpdateOne(ctx, id, data)
	if err != nil {
		return nil, fmt.Errorf("falha ao atualizar acesso de usuario: %w", err)
	}
	return result, nil
}

func (r *UserRepository) AddAddress(ctx context.Context, userID primitive.ObjectID, address *models.Address) ([]models.Address, error) {
	ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()

	if address.ID.IsZero() {
		address.ID = primitive.NewObjectID()
	}

	// Filtro para encontrar o usuário
	filter := bson.M{"_id": userID}

	update := bson.M{
		"$push": bson.M{
			"addresses": address,
		},
	}

	after := options.After
	opts := options.FindOneAndUpdateOptions{
		ReturnDocument: &after,
	}

	var updatedUser models.AddressesListEntity
	if err := r.coll.FindOneAndUpdate(ctx, filter, update, &opts).Decode(&updatedUser); err != nil {
		if errors.Is(err, mongo.ErrNoDocuments) {
			return nil, fmt.Errorf("usuário não encontrado")
		}
		return nil, fmt.Errorf("falha ao remover endereço: %w", err)
	}
	return updatedUser.Addresses, nil
}
func (r *UserRepository) UpdateAddress(ctx context.Context, userID primitive.ObjectID, addressID primitive.ObjectID, address *models.Address) ([]models.Address, error) {
	ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()

	setFields := bson.M{}
	if address.Street != "" {
		setFields["addresses.$[elem].street"] = address.Street
	}
	if address.Number != "" {
		setFields["addresses.$[elem].number"] = address.Number
	}
	if address.City != "" {
		setFields["addresses.$[elem].city"] = address.City
	}
	if address.State != "" {
		setFields["addresses.$[elem].state"] = address.State
	}
	if address.Zip != "" {
		setFields["addresses.$[elem].zip"] = address.Zip
	}
	if address.Complement != "" {
		setFields["addresses.$[elem].complement"] = address.Complement
	}
	if address.Neighborhood != "" {
		setFields["addresses.$[elem].neighborhood"] = address.Neighborhood
	}

	if len(setFields) == 0 {
		return nil, fmt.Errorf("nenhum dado fornecido para atualização")
	}

	update := bson.M{"$set": setFields}

	// Configurações avançadas
	opts := options.FindOneAndUpdate().
		SetArrayFilters(options.ArrayFilters{
			Filters: []interface{}{bson.M{"elem._id": addressID}},
		}).
		SetReturnDocument(options.After).
		SetProjection(bson.M{"addresses": 1})

	var result struct {
		Addresses []models.Address `bson:"addresses"`
	}

	if err := r.coll.FindOneAndUpdate(ctx, bson.M{"_id": userID, "addresses._id": addressID}, update, opts).
		Decode(&result); err != nil {
		if errors.Is(err, mongo.ErrNoDocuments) {
			return nil, fmt.Errorf("usuário ou endereço não encontrado")
		}
		return nil, err
	}

	return result.Addresses, nil
}

func (r *UserRepository) DeleteAddress(ctx context.Context, userID primitive.ObjectID, addressID primitive.ObjectID) ([]models.Address, error) {
	ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()

	// Filtro para encontrar o usuário
	filter := bson.M{"_id": userID}

	// Operação de remoção no array
	update := bson.M{
		"$pull": bson.M{
			"addresses": bson.M{"_id": addressID},
		},
	}

	// Configuração para retornar o documento APÓS a atualização
	after := options.After
	opts := options.FindOneAndUpdateOptions{
		ReturnDocument: &after,
	}

	var updatedUser models.AddressesListEntity
	err := r.coll.FindOneAndUpdate(ctx, filter, update, &opts).Decode(&updatedUser)

	if err != nil {
		if errors.Is(err, mongo.ErrNoDocuments) {
			return nil, fmt.Errorf("usuário não encontrado")
		}
		return nil, fmt.Errorf("falha ao remover endereço: %w", err)
	}

	return updatedUser.Addresses, nil
}

func (r *UserRepository) GetAddresses(ctx context.Context, userID primitive.ObjectID) ([]models.Address, *primitive.ObjectID, error) {
	ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()

	var result models.AddressesListEntity

	err := r.coll.FindOne(ctx, bson.M{"_id": userID}, options.FindOne().SetProjection(bson.M{
		"addresses":        1,
		"defaultAddressId": 1,
	})).Decode(&result)
	if err != nil {
		return nil, nil, err
	}
	return result.Addresses, result.DefaultAddressID, nil
}

func (r *UserRepository) SetDefaultAddress(ctx context.Context, userID primitive.ObjectID, addressID primitive.ObjectID) error {
	ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()

	// Ensure address exists
	filter := bson.M{"_id": userID, "addresses._id": addressID}
	update := bson.M{"$set": bson.M{"defaultAddressId": addressID}}

	res, err := r.coll.UpdateOne(ctx, filter, update)
	if err != nil {
		return fmt.Errorf("falha ao definir endereço padrão: %w", err)
	}
	if res.MatchedCount == 0 {
		return mongo.ErrNoDocuments
	}
	return nil
}

func (r *UserRepository) ClearDefaultAddress(ctx context.Context, userID primitive.ObjectID) error {
	ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	update := bson.M{"$unset": bson.M{"defaultAddressId": ""}}
	_, err := r.coll.UpdateOne(ctx, bson.M{"_id": userID}, update)
	return err
}

func (r *UserRepository) SetPasswordResetToken(ctx context.Context, userID primitive.ObjectID, codeHash string, expiresAt time.Time) error {
	ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	_, err := r.coll.UpdateOne(ctx, bson.M{"_id": userID}, bson.M{
		"$set": bson.M{
			"passwordResetCodeHash":  codeHash,
			"passwordResetExpiresAt": expiresAt,
		},
	})
	return err
}

func (r *UserRepository) ClearPasswordResetFields(ctx context.Context, userID primitive.ObjectID) error {
	ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	_, err := r.coll.UpdateOne(ctx, bson.M{"_id": userID}, bson.M{
		"$unset": bson.M{
			"passwordResetCodeHash":  "",
			"passwordResetExpiresAt": "",
		},
	})
	return err
}

func (r *UserRepository) UpdatePasswordClearReset(ctx context.Context, userID primitive.ObjectID, passwordHash string) error {
	ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	_, err := r.coll.UpdateOne(ctx, bson.M{"_id": userID}, bson.M{
		"$set": bson.M{"password": passwordHash},
		"$unset": bson.M{
			"passwordResetCodeHash":  "",
			"passwordResetExpiresAt": "",
		},
	})
	return err
}

func (r *UserRepository) GetFCMTokens(ctx context.Context, userID primitive.ObjectID) ([]string, error) {
	ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()

	var doc struct {
		Tokens []string `bson:"fcmTokens"`
	}
	err := r.coll.FindOne(ctx, bson.M{"_id": userID}, options.FindOne().SetProjection(bson.M{"fcmTokens": 1})).Decode(&doc)
	if err != nil {
		if errors.Is(err, mongo.ErrNoDocuments) {
			return nil, nil
		}
		return nil, err
	}
	return doc.Tokens, nil
}

func (r *UserRepository) AddFCMToken(ctx context.Context, userID primitive.ObjectID, token string) error {
	ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()

	res, err := r.coll.UpdateOne(ctx, bson.M{"_id": userID}, bson.M{
		"$addToSet": bson.M{"fcmTokens": token},
	})
	if err != nil {
		return err
	}
	if res.MatchedCount == 0 {
		return mongo.ErrNoDocuments
	}
	return nil
}
