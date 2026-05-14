package utils

import "testing"

// Garante que rótulos usados em handlers/respostas não foram apagados ou renomeados sem querer.
func TestLabels_ExpectedValues(t *testing.T) {
	if ErrorLabel != "error" {
		t.Fatalf("ErrorLabel=%q", ErrorLabel)
	}
	if EmptyString != "" {
		t.Fatalf("EmptyString=%q", EmptyString)
	}
	if ErrCodeInvalidOrExpir == "" {
		t.Fatal("ErrCodeInvalidOrExpir empty")
	}
	if Function != "function" {
		t.Fatalf("Function=%q", Function)
	}
}
