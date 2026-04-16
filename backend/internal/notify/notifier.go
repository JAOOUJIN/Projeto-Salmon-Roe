package notify

import (
	"context"
	"encoding/json"

	"go.mongodb.org/mongo-driver/bson/primitive"
)

// OrderStatusNotifier notifica o cliente dono do pedido (WebSocket + FCM).
type OrderStatusNotifier interface {
	NotifyOrderStatus(ctx context.Context, userID primitive.ObjectID, saleMongoID primitive.ObjectID, salesCD int64, status string)
}

type orderStatusWSMessage struct {
	Type    string `json:"type"`
	SaleID  string `json:"saleId"`
	CdVenda int64  `json:"cd_venda"`
	Status  string `json:"status"`
}

// Composite envia pelo hub WebSocket e pelo FCM quando configurados.
type Composite struct {
	Hub *Hub
	FCM *FCMSender
}

func (c *Composite) NotifyOrderStatus(ctx context.Context, userID primitive.ObjectID, saleMongoID primitive.ObjectID, salesCD int64, status string) {
	if c == nil {
		return
	}
	payload, err := json.Marshal(orderStatusWSMessage{
		Type:    "order_status",
		SaleID:  saleMongoID.Hex(),
		CdVenda: salesCD,
		Status:  status,
	})
	if err != nil {
		return
	}
	if c.Hub != nil {
		c.Hub.SendToUser(userID.Hex(), payload)
	}
	if c.FCM != nil {
		c.FCM.SendOrderStatus(ctx, userID, saleMongoID, salesCD, status)
	}
}
