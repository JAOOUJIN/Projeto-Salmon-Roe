package mail

import (
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"net/url"
	"strings"
	"testing"

	"github.com/resend/resend-go/v3"
)

func TestNewPasswordResetMailerFromEnv_MissingBoth(t *testing.T) {
	t.Setenv("RESEND_API_KEY", "")
	t.Setenv("RESEND_FROM", "")
	m, ok := NewPasswordResetMailerFromEnv()
	if ok || m != nil {
		t.Fatalf("ok=%v m=%v", ok, m)
	}
}

func TestNewPasswordResetMailerFromEnv_MissingKey(t *testing.T) {
	t.Setenv("RESEND_API_KEY", "")
	t.Setenv("RESEND_FROM", "onboarding@example.com")
	m, ok := NewPasswordResetMailerFromEnv()
	if ok || m != nil {
		t.Fatalf("ok=%v m=%v", ok, m)
	}
}

func TestNewPasswordResetMailerFromEnv_MissingFrom(t *testing.T) {
	t.Setenv("RESEND_API_KEY", "re_xxx")
	t.Setenv("RESEND_FROM", "")
	m, ok := NewPasswordResetMailerFromEnv()
	if ok || m != nil {
		t.Fatalf("ok=%v m=%v", ok, m)
	}
}

func TestNewPasswordResetMailerFromEnv_TrimAndOK(t *testing.T) {
	t.Setenv("RESEND_API_KEY", "  re_secret  ")
	t.Setenv("RESEND_FROM", "  noreply@example.com  ")
	m, ok := NewPasswordResetMailerFromEnv()
	if !ok || m == nil {
		t.Fatalf("ok=%v m=%v", ok, m)
	}
	// Garante que o construtor devolve o tipo esperado da interface.
	_ = PasswordResetMailer(m)
}

func TestResendSender_SendPasswordResetCode_Success(t *testing.T) {
	const wantCode = "654321"
	const wantFrom = "reset@example.com"
	const wantTo = "user@example.com"

	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost || r.URL.Path != "/emails" {
			t.Errorf("request %s %s", r.Method, r.URL.Path)
			http.NotFound(w, r)
			return
		}
		if got := r.Header.Get("Authorization"); got != "Bearer test-api-key" {
			t.Errorf("Authorization=%q", got)
		}
		body, err := io.ReadAll(r.Body)
		if err != nil {
			t.Error(err)
			http.Error(w, "read", http.StatusInternalServerError)
			return
		}
		var payload struct {
			From    string   `json:"from"`
			To      []string `json:"to"`
			Subject string   `json:"subject"`
			Text    string   `json:"text"`
		}
		if err := json.Unmarshal(body, &payload); err != nil {
			t.Error(err)
			http.Error(w, "json", http.StatusBadRequest)
			return
		}
		if payload.From != wantFrom {
			t.Errorf("from=%q", payload.From)
		}
		if len(payload.To) != 1 || payload.To[0] != wantTo {
			t.Errorf("to=%v", payload.To)
		}
		if payload.Subject != "Código para redefinir sua senha" {
			t.Errorf("subject=%q", payload.Subject)
		}
		if !strings.Contains(payload.Text, wantCode) {
			t.Errorf("text missing code: %q", payload.Text)
		}
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte(`{"id":"em_test_1"}`))
	}))
	t.Cleanup(srv.Close)

	base, err := url.Parse(srv.URL + "/")
	if err != nil {
		t.Fatal(err)
	}
	client := resend.NewCustomClient(srv.Client(), "test-api-key")
	client.BaseURL = base

	sender := &resendSender{client: client, from: wantFrom}
	if err := sender.SendPasswordResetCode(wantTo, wantCode); err != nil {
		t.Fatal(err)
	}
}

func TestResendSender_SendPasswordResetCode_APIError(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusUnauthorized)
		_, _ = w.Write([]byte(`{"message":"Invalid API key"}`))
	}))
	t.Cleanup(srv.Close)

	base, err := url.Parse(srv.URL + "/")
	if err != nil {
		t.Fatal(err)
	}
	client := resend.NewCustomClient(srv.Client(), "bad-key")
	client.BaseURL = base

	sender := &resendSender{client: client, from: "from@x.co"}
	if err := sender.SendPasswordResetCode("to@x.co", "111111"); err == nil {
		t.Fatal("expected error")
	}
}
