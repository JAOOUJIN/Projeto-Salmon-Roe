package utils

import (
	"context"
	"log/slog"
	"runtime"
)

type ctxKey struct{}

var key = ctxKey{}

func WithLogger(ctx context.Context, logger *slog.Logger) context.Context {
	return context.WithValue(ctx, key, logger)
}

func LoggerFromContext(ctx context.Context) *slog.Logger {
	if logger, ok := ctx.Value(key).(*slog.Logger); ok {
		return logger
	}

	return slog.Default()
}

func FnCallerName() string {
	pc, _, _, ok := runtime.Caller(1)
	if !ok {
		return ""
	}
	f := runtime.FuncForPC(pc)
	if f == nil {
		return ""
	}
	return f.Name()
}
