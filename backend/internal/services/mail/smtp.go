package mail

import (
	"crypto/tls" // Importação necessária para SSL/TLS na porta 465
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
		port = "587" // Mantém padrão 587 caso vazio
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
	
	// Montagem do e-mail formatado
	msg := fmt.Sprintf("From: %s\r\nTo: %s\r\nSubject: %s\r\nMIME-Version: 1.0\r\nContent-Type: text/plain; charset=UTF-8\r\n\r\n%s",
		s.from, to, subject, body)

	addr := fmt.Sprintf("%s:%s", s.host, s.port)

	// Se a porta for 465, precisamos de conexão TLS direta
	if s.port == "465" {
		tlsConfig := &tls.Config{
			InsecureSkipVerify: false,
			ServerName:         s.host,
		}

		// Conecta via TLS (SSL implícito)
		conn, err := tls.Dial("tcp", addr, tlsConfig)
		if err != nil {
			return fmt.Errorf("falha no tls dial: %v", err)
		}
		defer conn.Close()

		client, err := smtp.NewClient(conn, s.host)
		if err != nil {
			return fmt.Errorf("falha ao criar cliente smtp: %v", err)
		}
		defer client.Quit()

		// Autenticação
		if s.user != "" {
			auth := smtp.PlainAuth("", s.user, s.pass, s.host)
			if err = client.Auth(auth); err != nil {
				return fmt.Errorf("falha na autenticação: %v", err)
			}
		}

		// Fluxo de envio
		if err = client.Mail(s.from); err != nil {
			return err
		}
		if err = client.Rcpt(to); err != nil {
			return err
		}

		w, err := client.Data()
		if err != nil {
			return err
		}

		_, err = w.Write([]byte(msg))
		if err != nil {
			return err
		}

		return w.Close()
	}

	// Caso usem outra porta (como 587 localmente), mantém o comportamento original
	var auth smtp.Auth
	if s.user != "" {
		auth = smtp.PlainAuth("", s.user, s.pass, s.host)
	}
	return smtp.SendMail(addr, auth, s.from, []string{to}, []byte(msg))
}