package mail

import (
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestNewWebhookMailerFromEnv_MissingURL(t *testing.T) {
	t.Setenv("MAKE_WEBHOOK_URL", "")
	m, ok := NewWebhookMailerFromEnv()
	if ok || m != nil {
		t.Fatalf("esperava ok=false e m=nil, obteve ok=%v m=%v", ok, m)
	}
}

func TestNewWebhookMailerFromEnv_TrimAndOK(t *testing.T) {
	t.Setenv("MAKE_WEBHOOK_URL", "  https://hook.us2.make.com/exemplo  ")
	m, ok := NewWebhookMailerFromEnv()
	if !ok || m == nil {
		t.Fatalf("esperava ok=true e m!=nil, obteve ok=%v m=%v", ok, m)
	}
	// Garante que o construtor devolve o tipo esperado da interface.
	_ = PasswordResetMailer(m)
}

func TestWebhookSender_SendPasswordResetCode_Success(t *testing.T) {
	const wantCode = "654321"
	const wantTo = "seungjin@example.com"

	// Cria um servidor falso (mock) para fingir ser o Make.com
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			t.Errorf("método de requisição %s, esperado %s", r.Method, http.MethodPost)
			http.NotFound(w, r)
			return
		}

		body, err := io.ReadAll(r.Body)
		if err != nil {
			t.Error(err)
			http.Error(w, "erro ao ler body", http.StatusInternalServerError)
			return
		}

		// Verifica se o JSON chegou no formato exato que configuramos no Make.com
		var payload map[string]string
		if err := json.Unmarshal(body, &payload); err != nil {
			t.Error(err)
			http.Error(w, "erro no json", http.StatusBadRequest)
			return
		}

		if payload["email"] != wantTo {
			t.Errorf("email=%q, esperado %q", payload["email"], wantTo)
		}
		if payload["code"] != wantCode {
			t.Errorf("code=%q, esperado %q", payload["code"], wantCode)
		}

		// Responde com 200 OK igual o Make faz
		w.WriteHeader(http.StatusOK)
	}))
	t.Cleanup(srv.Close)

	// Instancia o nosso webhookSender apontando para o servidor falso
	sender := &webhookSender{webhookURL: srv.URL}
	if err := sender.SendPasswordResetCode(wantTo, wantCode); err != nil {
		t.Fatal(err)
	}
}

func TestWebhookSender_SendPasswordResetCode_APIError(t *testing.T) {
	// Cria um servidor falso que sempre retorna erro
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusInternalServerError)
	}))
	t.Cleanup(srv.Close)

	sender := &webhookSender{webhookURL: srv.URL}
	if err := sender.SendPasswordResetCode("to@x.co", "111111"); err == nil {
		t.Fatal("esperava um erro, mas obteve nil")
	}
}
