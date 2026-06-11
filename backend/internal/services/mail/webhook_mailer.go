package mail

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
	"time"
)

// PasswordResetMailer envia o código de recuperação de senha.
type PasswordResetMailer interface {
	SendPasswordResetCode(to, code string) error
}

type webhookSender struct {
	webhookURL string
}

// NewWebhookMailerFromEnv cria um mailer via Webhook quando MAKE_WEBHOOK_URL está definido.
func NewWebhookMailerFromEnv() (PasswordResetMailer, bool) {
	url := strings.TrimSpace(os.Getenv("MAKE_WEBHOOK_URL"))
	if url == "" {
		return nil, false
	}
	return &webhookSender{webhookURL: url}, true
}

func (s *webhookSender) SendPasswordResetCode(to, code string) error {
	payload := map[string]string{
		"email": to,
		"code":  code,
	}

	jsonData, err := json.Marshal(payload)
	if err != nil {
		return err
	}

	// Dispara o POST para o Make.com na porta 443 (HTTPS), que o Render não bloqueia
	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Post(s.webhookURL, "application/json", bytes.NewBuffer(jsonData))
	if err != nil {
		return fmt.Errorf("falha ao conectar com o webhook: %v", err)
	}
	defer func(Body io.ReadCloser) {
		err := Body.Close()
		if err != nil {

		}
	}(resp.Body)

	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return fmt.Errorf("o webhook retornou erro com status: %d", resp.StatusCode)
	}

	return nil
}
