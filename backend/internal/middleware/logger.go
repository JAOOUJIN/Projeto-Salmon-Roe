package middleware

import (
	"fmt"
	"log/slog"
	"math/rand"
	"time"

	"github.com/gin-gonic/gin"
)

func LoggerMiddleware(baseLogger *slog.Logger) gin.HandlerFunc {
	return func(c *gin.Context) {
		start := time.Now()
		traceID := fmt.Sprintf("%x", rand.Uint64())

		if traceIdHeader := c.GetHeader("X-rd-traceid"); traceIdHeader != "" {
			c.Header("X-rd-traceid", traceIdHeader)
			traceID = traceIdHeader
		} else {
			c.Header("X-rd-traceid", traceID)
		}

		ctxLogger := baseLogger.With(
			"trace_id", traceID,
			"ts", time.Now().Format(time.RFC3339),
			"method", c.Request.Method,
			"path", c.Request.URL.Path,
		)

		ctxLogger.Info("Requisição recebida")

		c.Next()
		ctxLogger.Info("Requisição concluída",
			"status", c.Writer.Status(),
			"duration", fmt.Sprintf("%vms", time.Since(start).Milliseconds()),
		)
	}
}
