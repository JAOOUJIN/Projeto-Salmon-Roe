package mail

import (
	"fmt"
	"os"
	"strings"

	"github.com/resend/resend-go/v3"
)

// PasswordResetMailer envia o código de recuperação de senha.
type PasswordResetMailer interface {
	SendPasswordResetCode(to, code string) error
}

type resendSender struct {
	client *resend.Client
	from   string
}

// NewPasswordResetMailerFromEnv cria um mailer Resend quando RESEND_API_KEY e RESEND_FROM estão definidos.
func NewPasswordResetMailerFromEnv() (PasswordResetMailer, bool) {
	key := strings.TrimSpace(os.Getenv("RESEND_API_KEY"))
	from := strings.TrimSpace(os.Getenv("RESEND_FROM"))
	if key == "" || from == "" {
		return nil, false
	}
	return &resendSender{client: resend.NewClient(key), from: from}, true
}

func (s *resendSender) SendPasswordResetCode(to, code string) error {
	subject := "Código para redefinir sua senha"
	body := fmt.Sprintf("Olá,\n\nUse o código abaixo para definir uma nova senha (válido por tempo limitado):\n\n%s\n\nSe você não solicitou, ignore este e-mail.\n", code)
	_, err := s.client.Emails.Send(&resend.SendEmailRequest{
		From:    s.from,
		To:      []string{to},
		Subject: subject,
		Text:    body,
	})
	return err
}
