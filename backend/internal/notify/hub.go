package notify

import (
	"sync"

	"github.com/gorilla/websocket"
)

// Hub mantém conexões WebSocket agrupadas por userID (string do JWT).
type Hub struct {
	mu         sync.RWMutex
	clients    map[string]map[*wsClient]struct{}
	register   chan *wsClient
	unregister chan *wsClient
}

type wsClient struct {
	hub    *Hub
	userID string
	conn   *websocket.Conn
	send   chan []byte
}

func NewHub() *Hub {
	return &Hub{
		clients:    make(map[string]map[*wsClient]struct{}),
		register:   make(chan *wsClient),
		unregister: make(chan *wsClient),
	}
}

func (h *Hub) Run() {
	for {
		select {
		case c := <-h.register:
			h.mu.Lock()
			if h.clients[c.userID] == nil {
				h.clients[c.userID] = make(map[*wsClient]struct{})
			}
			h.clients[c.userID][c] = struct{}{}
			h.mu.Unlock()
		case c := <-h.unregister:
			h.mu.Lock()
			if m, ok := h.clients[c.userID]; ok {
				delete(m, c)
				if len(m) == 0 {
					delete(h.clients, c.userID)
				}
			}
			h.mu.Unlock()
			close(c.send)
		}
	}
}

func newWSClient(hub *Hub, userID string, conn *websocket.Conn) *wsClient {
	return &wsClient{
		hub:    hub,
		userID: userID,
		conn:   conn,
		send:   make(chan []byte, 32),
	}
}

// SendToUser envia o mesmo payload JSON para todas as conexões ativas do usuário.
func (h *Hub) SendToUser(userID string, payload []byte) {
	h.mu.RLock()
	defer h.mu.RUnlock()
	for c := range h.clients[userID] {
		select {
		case c.send <- payload:
		default:
		}
	}
}

func (c *wsClient) readPump() {
	defer func() {
		c.hub.unregister <- c
		_ = c.conn.Close()
	}()
	for {
		if _, _, err := c.conn.ReadMessage(); err != nil {
			break
		}
	}
}

func (c *wsClient) writePump() {
	defer func() {
		_ = c.conn.Close()
	}()
	for msg := range c.send {
		if err := c.conn.WriteMessage(websocket.TextMessage, msg); err != nil {
			return
		}
	}
}
