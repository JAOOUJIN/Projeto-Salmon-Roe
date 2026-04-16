package mail

import (
	"fmt"
	"net/smtp"
	"os"
	"strings"
)

type Sender struct {
	host string
	port string
	user string
	pass string
	from string
}

func NewSenderFromEnv() (*Sender, bool) {
	host := strings.TrimSpace(os.Getenv("SMTP_HOST"))
	port := strings.TrimSpace(os.Getenv("SMTP_PORT"))
	if port == "" {
		port = "587"
	}
	user := strings.TrimSpace(os.Getenv("SMTP_USER"))
	pass := os.Getenv("SMTP_PASSWORD")
	from := strings.TrimSpace(os.Getenv("SMTP_FROM"))
	if host == "" || from == "" {
		return nil, false
	}
	return &Sender{host: host, port: port, user: user, pass: pass, from: from}, true
}

func (s *Sender) SendPasswordResetCode(to, code string) error {
	subject := "Código para redefinir sua senha"
	body := fmt.Sprintf("Olá,\n\nUse o código abaixo para definir uma nova senha (válido por tempo limitado):\n\n%s\n\nSe você não solicitou, ignore este e-mail.\n", code)
	msg := []byte(fmt.Sprintf("From: %s\r\nTo: %s\r\nSubject: %s\r\nMIME-Version: 1.0\r\nContent-Type: text/plain; charset=UTF-8\r\n\r\n%s",
		s.from, to, subject, body))

	addr := fmt.Sprintf("%s:%s", s.host, s.port)
	var auth smtp.Auth
	if s.user != "" {
		auth = smtp.PlainAuth("", s.user, s.pass, s.host)
	}
	return smtp.SendMail(addr, auth, s.from, []string{to}, msg)
}
