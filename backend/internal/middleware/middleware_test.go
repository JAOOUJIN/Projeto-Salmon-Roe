package middleware

import (
	"bytes"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"backend-app/internal/config/auth"

	"github.com/gin-gonic/gin"
)

func TestAuthRequired_MissingHeader(t *testing.T) {
	gin.SetMode(gin.TestMode)
	jm := auth.NewJWTManager("secret-mw-test", time.Hour)
	r := gin.New()
	r.Use(AuthRequired(jm))
	r.GET("/x", func(c *gin.Context) { c.Status(http.StatusOK) })

	req := httptest.NewRequest(http.MethodGet, "/x", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusUnauthorized {
		t.Fatalf("status=%d body=%s", w.Code, w.Body.String())
	}
	if !strings.Contains(w.Body.String(), "token ausente") {
		t.Fatalf("body=%s", w.Body.String())
	}
}

func TestAuthRequired_NotBearer(t *testing.T) {
	gin.SetMode(gin.TestMode)
	jm := auth.NewJWTManager("secret-mw-test", time.Hour)
	r := gin.New()
	r.Use(AuthRequired(jm))
	r.GET("/x", func(c *gin.Context) { c.Status(http.StatusOK) })

	req := httptest.NewRequest(http.MethodGet, "/x", nil)
	req.Header.Set("Authorization", "Basic xxx")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusUnauthorized {
		t.Fatalf("status=%d", w.Code)
	}
}

func TestAuthRequired_InvalidToken(t *testing.T) {
	gin.SetMode(gin.TestMode)
	jm := auth.NewJWTManager("secret-mw-test", time.Hour)
	r := gin.New()
	r.Use(AuthRequired(jm))
	r.GET("/x", func(c *gin.Context) { c.Status(http.StatusOK) })

	req := httptest.NewRequest(http.MethodGet, "/x", nil)
	req.Header.Set("Authorization", "Bearer not-a-jwt")
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusUnauthorized {
		t.Fatalf("status=%d body=%s", w.Code, w.Body.String())
	}
	if !strings.Contains(w.Body.String(), "token inválido") {
		t.Fatalf("body=%s", w.Body.String())
	}
}

func TestAuthRequired_OK_SetsContext(t *testing.T) {
	gin.SetMode(gin.TestMode)
	jm := auth.NewJWTManager("secret-mw-test", time.Hour)
	token, err := jm.Generate("507f1f77bcf86cd799439011", "user@example.com")
	if err != nil {
		t.Fatal(err)
	}

	var gotUID, gotEmail string
	r := gin.New()
	r.Use(AuthRequired(jm))
	r.GET("/x", func(c *gin.Context) {
		uid, _ := c.Get("userId")
		email, _ := c.Get("userEmail")
		gotUID = uid.(string)
		gotEmail = email.(string)
		c.Status(http.StatusOK)
	})

	req := httptest.NewRequest(http.MethodGet, "/x", nil)
	req.Header.Set("Authorization", "Bearer "+token)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("status=%d", w.Code)
	}
	if gotUID != "507f1f77bcf86cd799439011" {
		t.Fatalf("userId=%v", gotUID)
	}
	if gotEmail != "user@example.com" {
		t.Fatalf("userEmail=%v", gotEmail)
	}
}

func TestCORS_OPTIONS_AbortsWith204(t *testing.T) {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	r.Use(CORS())
	r.GET("/x", func(c *gin.Context) { c.Status(http.StatusOK) })

	req := httptest.NewRequest(http.MethodOptions, "/x", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusNoContent {
		t.Fatalf("status=%d", w.Code)
	}
	if w.Header().Get("Access-Control-Allow-Origin") != "*" {
		t.Fatalf("CORS origin header missing")
	}
}

func TestCORS_GET_SetsHeadersAndNext(t *testing.T) {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	r.Use(CORS())
	r.GET("/x", func(c *gin.Context) { c.String(http.StatusOK, "ok") })

	req := httptest.NewRequest(http.MethodGet, "/x", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK || w.Body.String() != "ok" {
		t.Fatalf("status=%d body=%q", w.Code, w.Body.String())
	}
	if w.Header().Get("Access-Control-Allow-Origin") != "*" {
		t.Fatal("missing Allow-Origin")
	}
	if !strings.Contains(w.Header().Get("Access-Control-Allow-Headers"), "Authorization") {
		t.Fatalf("Allow-Headers=%q", w.Header().Get("Access-Control-Allow-Headers"))
	}
}

func TestLoggerMiddleware_GeneratedTraceID(t *testing.T) {
	gin.SetMode(gin.TestMode)
	var buf bytes.Buffer
	h := slog.NewTextHandler(&buf, &slog.HandlerOptions{Level: slog.LevelInfo})
	log := slog.New(h)

	r := gin.New()
	r.Use(LoggerMiddleware(log))
	r.GET("/path", func(c *gin.Context) { c.Status(http.StatusTeapot) })

	req := httptest.NewRequest(http.MethodGet, "/path", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Header().Get("X-rd-traceid") == "" {
		t.Fatal("expected X-rd-traceid response header")
	}
	out := buf.String()
	if !strings.Contains(out, "Requisição recebida") || !strings.Contains(out, "Requisição concluída") {
		t.Fatalf("logs=%q", out)
	}
	if !strings.Contains(out, "trace_id=") {
		t.Fatalf("logs=%q", out)
	}
	if !strings.Contains(out, "status=418") {
		t.Fatalf("logs=%q", out)
	}
}

func TestLoggerMiddleware_IncomingTraceID(t *testing.T) {
	gin.SetMode(gin.TestMode)
	var buf bytes.Buffer
	log := slog.New(slog.NewTextHandler(&buf, &slog.HandlerOptions{Level: slog.LevelInfo}))

	r := gin.New()
	r.Use(LoggerMiddleware(log))
	r.GET("/a", func(c *gin.Context) { c.Status(http.StatusOK) })

	const wantTrace = "client-trace-abc-123"
	req := httptest.NewRequest(http.MethodGet, "/a", nil)
	req.Header.Set("X-rd-traceid", wantTrace)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if got := w.Header().Get("X-rd-traceid"); got != wantTrace {
		t.Fatalf("response X-rd-traceid=%q want %q", got, wantTrace)
	}
	if !strings.Contains(buf.String(), wantTrace) {
		t.Fatalf("logs should include trace: %q", buf.String())
	}
}
