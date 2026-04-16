package notify

import (
	"net/http"
	"strings"

	"backend-app/internal/config/auth"

	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
)

var wsUpgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

// ServeWebSocket faz upgrade da conexão; autenticação via query ?token=JWT ou header Authorization.
func ServeWebSocket(c *gin.Context, jwtManager *auth.JWTManager, hub *Hub) {
	token := c.Query("token")
	if token == "" {
		token = strings.TrimPrefix(c.GetHeader("Authorization"), "Bearer ")
	}
	if token == "" || jwtManager == nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "token ausente"})
		return
	}
	claims, err := jwtManager.Parse(token)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "token inválido"})
		return
	}

	conn, err := wsUpgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		return
	}

	client := newWSClient(hub, claims.UserID, conn)
	hub.register <- client
	go client.writePump()
	client.readPump()
}
