package environment

import (
	"backend-app/internal/models"
	"backend-app/internal/utils"
	"fmt"
	"log/slog"
	"os"
	"strconv"
	"time"

	"github.com/joho/godotenv"
)

var Logger = slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
	Level:     slog.LevelInfo,
	AddSource: true,
}))

var PORTA int

func InitEnv() error {
	_ = godotenv.Overload(".env")

	port := os.Getenv("API_PORT")
	if port != "" {
		var err error
		PORTA, err = strconv.Atoi(port)
		if err != nil {
			return fmt.Errorf("invalid API_PORT: %v", err)
		}
	}

	var level slog.Level

	switch os.Getenv("LOG_LEVEL") {
	case "ERROR":
		level = slog.LevelError
	case "DEBUG":
		level = slog.LevelDebug
	case "WARN":
		level = slog.LevelWarn
	default:
		level = slog.LevelInfo
	}

	Logger = slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
		Level:     level,
		AddSource: true,
	}))

	return nil
}

func LoadConfigureJWT() models.ConfigJWT {
	JwtExpiresHours, errJwtExpiresHours := strconv.Atoi(os.Getenv("JWT_EXPIRES_HOURS"))
	if errJwtExpiresHours != nil {
		JwtExpiresHours = utils.JWTExpiresHours
	}

	return models.ConfigJWT{
		JWTSecret:    os.Getenv("JWT_SECRET"),
		JWTExpiresIn: time.Duration(JwtExpiresHours) * time.Hour,
	}
}
