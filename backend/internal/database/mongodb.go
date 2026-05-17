package database

import (
	"context"
	"log"
	"os"
	"time"

	"go.mongodb.org/mongo-driver/event"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

var (
	Client       *mongo.Client
	DatabaseName string
)

var defaultTimeout = 10 * time.Second

func Ctx() context.Context {
	ctx, _ := context.WithTimeout(context.Background(), defaultTimeout)
	return ctx
}

const LogPrefix = "[DB INFO]"

func ConnectDB() *mongo.Client {
	log.SetPrefix(LogPrefix)
	log.SetFlags(log.Ldate | log.Ltime | log.Lshortfile)

	mongoURI := os.Getenv("DB_URL")
	log.Printf("Iniciando conexão ao URI: %s", mongoURI)

	cmdMonitor := &event.CommandMonitor{
		Started: func(_ context.Context, evt *event.CommandStartedEvent) {
			// ** Aqui é onde você vê o RAW Command (o que é enviado ao MongoDB) **
			log.Printf("CMD_START: Name=%s | Command=%s", evt.CommandName, evt.Command)
		},
		Succeeded: func(_ context.Context, evt *event.CommandSucceededEvent) {
			log.Printf("CMD_SUCCESS: Name=%s | Duration=%dms", evt.CommandName, evt.DurationNanos/1e6)
		},
		Failed: func(_ context.Context, evt *event.CommandFailedEvent) {
			log.Printf("CMD_FAILED: Name=%s | Error=%s", evt.CommandName, evt.Failure)
		},
	}
	// -----------------------------------------------------------------

	clientOptions := options.Client().
		ApplyURI(mongoURI).
		SetMonitor(cmdMonitor)

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	client, err := mongo.Connect(ctx, clientOptions)
	if err != nil {
		log.Fatal("Falha crítica ao criar cliente MongoDB: ", err)
	}

	err = client.Ping(context.TODO(), nil)
	if err != nil {
		log.Fatal("Falha crítica ao pingar o MongoDB: ", err)
	}

	DatabaseName = os.Getenv("DB_NAME")
	log.Println("Conexão ao MongoDB estabelecida com sucesso! ✅")

	Client = client
	return client
}

func GetCollection(collectionName string) *mongo.Collection {
	return Client.Database(DatabaseName).Collection(collectionName)
}
