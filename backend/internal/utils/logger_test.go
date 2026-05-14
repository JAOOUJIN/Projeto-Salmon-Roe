package utils

import (
	"bytes"
	"context"
	"log/slog"
	"strings"
	"testing"
)

func TestWithLogger_LoggerFromContext(t *testing.T) {
	var buf bytes.Buffer
	lg := slog.New(slog.NewTextHandler(&buf, nil))
	ctx := WithLogger(context.Background(), lg)

	got := LoggerFromContext(ctx)
	if got != lg {
		t.Fatal("LoggerFromContext should return the same logger instance")
	}
}

func TestLoggerFromContext_Default(t *testing.T) {
	got := LoggerFromContext(context.Background())
	if got == nil {
		t.Fatal("expected non-nil slog.Default()")
	}
	if got != slog.Default() {
		t.Fatal("expected slog.Default() when no logger in context")
	}
}

func TestFnCallerName_FromTest(t *testing.T) {
	name := FnCallerName()
	if name == "" {
		t.Fatal("expected non-empty caller name")
	}
	if !strings.Contains(name, "TestFnCallerName_FromTest") {
		t.Fatalf("unexpected caller: %q", name)
	}
}

func helperCallsFnCallerName() string {
	return FnCallerName()
}

func TestFnCallerName_FromHelper(t *testing.T) {
	name := helperCallsFnCallerName()
	if name == "" {
		t.Fatal("expected non-empty caller name")
	}
	if !strings.Contains(name, "helperCallsFnCallerName") {
		t.Fatalf("expected helper in name, got %q", name)
	}
}
