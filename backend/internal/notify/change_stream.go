package notify

import (
	"context"
	"fmt"
	"log/slog"
	"os"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

// Estrutura do evento que o MongoDB envia no Change Stream
type saleChangeEvent struct {
	OperationType string `bson:"operationType"`
	DocumentKey   struct {
		ID primitive.ObjectID `bson:"_id"`
	} `bson:"documentKey"`
	FullDocument struct {
		UserID  primitive.ObjectID `bson:"user_id"`
		CdVenda int64              `bson:"cd_venda"`
		Status  string             `bson:"status"`
	} `bson:"fullDocument"`
}

// StartSalesChangeStream inicia a escuta das mudanças na collection sales.
func StartSalesChangeStream(client *mongo.Client, notifier OrderStatusNotifier) {
	dbName := os.Getenv("DB_NAME")
	collName := os.Getenv("COLLECTION_NAME_SALES")

	collection := client.Database(dbName).Collection(collName)

	// Filtra para ouvir apenas as operações de 'update'
	pipeline := mongo.Pipeline{
		bson.D{{Key: "$match", Value: bson.D{{Key: "operationType", Value: "update"}}}},
	}

	// UpdateLookup diz ao Mongo para nos enviar o documento completo (para termos o userID e cd_venda)
	opts := options.ChangeStream().SetFullDocument(options.UpdateLookup)

	stream, err := collection.Watch(context.TODO(), pipeline, opts)
	if err != nil {
		slog.Error("Falha ao abrir Change Stream", "err", err)
		return
	}
	defer func(stream *mongo.ChangeStream, ctx context.Context) {
		err := stream.Close(ctx)
		if err != nil {

		}
	}(stream, context.TODO())

	fmt.Println("Ouvindo mudanças na collection de Vendas (Change Streams)")

	for stream.Next(context.TODO()) {
		var event saleChangeEvent
		if err := stream.Decode(&event); err != nil {
			slog.Error("Erro ao decodificar evento do Change Stream", "err", err)
			continue
		}

		// Garante que não é um documento vazio e chama o notificador
		if !event.FullDocument.UserID.IsZero() {
			fmt.Printf("Change Stream: Venda %s atualizada para status: %s\n", event.DocumentKey.ID.Hex(), event.FullDocument.Status)

			// Usa o seu Composite Notifier existente!
			notifier.NotifyOrderStatus(
				context.Background(),
				event.FullDocument.UserID,
				event.DocumentKey.ID,
				event.FullDocument.CdVenda,
				event.FullDocument.Status,
			)
		}
	}
}
