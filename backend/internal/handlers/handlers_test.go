package handlers

import (
	"backend-app/internal/utils"
	"context"
	"io"
	"log/slog"
	"net/http/httptest"

	"github.com/gin-gonic/gin"
)

func testContext(method, path string, body io.Reader) (*gin.Context, *httptest.ResponseRecorder) {
	gin.SetMode(gin.TestMode)
	w := httptest.NewRecorder()
	c, _ := gin.CreateTestContext(w)
	req := httptest.NewRequest(method, path, body)
	req.Header.Set("Content-Type", "application/json")
	c.Request = req.WithContext(utils.WithLogger(context.Background(), slog.Default()))
	return c, w
}
