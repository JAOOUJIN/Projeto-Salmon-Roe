package notify

import (
	"context"
	"fmt"
	"log/slog"
	"os"
	"strconv"

	"backend-app/internal/utils"

	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/messaging"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"google.golang.org/api/option"
)

type FCMTokenProvider interface {
	GetFCMTokens(ctx context.Context, userID primitive.ObjectID) ([]string, error)
}

// FCMSender envia notificações data+notification via FCM (quando credenciais estão configuradas).
type FCMSender struct {
	client *messaging.Client
	tokens FCMTokenProvider
	log    *slog.Logger
}

// NewFCMSender retorna nil se FIREBASE_CREDENTIALS_PATH e FIREBASE_CREDENTIALS_JSON estiverem vazios.
func NewFCMSender(ctx context.Context, tokens FCMTokenProvider, log *slog.Logger) (*FCMSender, error) {
	path := os.Getenv("FIREBASE_CREDENTIALS_PATH")
	jsonStr := os.Getenv("FIREBASE_CREDENTIALS_JSON")
	if path == "" && jsonStr == "" {
		if log != nil {
			log.Info("FCM desabilitado: defina FIREBASE_CREDENTIALS_PATH ou FIREBASE_CREDENTIALS_JSON")
		}
		return nil, nil
	}

	var opt option.ClientOption
	if jsonStr != "" {
		opt = option.WithCredentialsJSON([]byte(jsonStr))
	} else {
		opt = option.WithCredentialsFile(path)
	}

	app, err := firebase.NewApp(ctx, nil, opt)
	if err != nil {
		return nil, fmt.Errorf("firebase.NewApp: %w", err)
	}

	client, err := app.Messaging(ctx)
	if err != nil {
		return nil, fmt.Errorf("firebase Messaging: %w", err)
	}

	return &FCMSender{client: client, tokens: tokens, log: log}, nil
}

func (f *FCMSender) SendOrderStatus(ctx context.Context, userID primitive.ObjectID, saleMongoID primitive.ObjectID, salesCD int64, status string) {
	if f == nil || f.client == nil || f.tokens == nil {
		return
	}

	tokens, err := f.tokens.GetFCMTokens(ctx, userID)
	if err != nil {
		if f.log != nil {
			f.log.Warn("fcm: falha ao ler tokens", "userId", userID.Hex(), "error", err.Error())
		}
		return
	}
	if len(tokens) == 0 {
		return
	}

	data := map[string]string{
		"type":     "order_status",
		"saleId":   saleMongoID.Hex(),
		"cd_venda": strconv.FormatInt(salesCD, 10),
		"status":   status,
	}

	title := "Pedido atualizado"
	body := statusLabel(status)

	for _, tok := range tokens {
		msg := &messaging.Message{
			Token: tok,
			Data:  data,
			Notification: &messaging.Notification{
				Title: title,
				Body:  body,
			},
		}
		if _, err := f.client.Send(ctx, msg); err != nil {
			if f.log != nil {
				f.log.Warn("fcm: envio falhou", "error", err.Error())
			}
		}
	}
}

func statusLabel(s string) string {
	switch s {
	case utils.StatusPending:
		return "Seu pedido está pendente."
	case utils.StatusConfirmed:
		return "Pedido confirmado."
	case utils.StatusShipped:
		return "Pedido enviado."
	case utils.StatusOnTheWay:
		return "Pedido a caminho."
	case utils.StatusDelivered:
		return "Pedido entregue."
	case utils.StatusCancelled:
		return "Pedido cancelado."
	default:
		return "Status do pedido: " + s
	}
}
