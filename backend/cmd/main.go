package main

import (
	"backend-app/internal/config/database"
	"backend-app/internal/config/environment"
	"backend-app/internal/router"
	"backend-app/internal/utils"
	"fmt"
	"log"
	"log/slog"
	"os"
	"time"
)

func main() {
	loc, _ := time.LoadLocation(utils.TimeZoneSP)
	time.Local = loc
	baseLogger := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
		Level: slog.LevelDebug,
	}))

	if err := environment.InitEnv(); err != nil {
		baseLogger.Error("falha ao carregar variáveis de ambiente: %v", err)
		return
	}

	mongoClient := database.ConnectDB()

	r := router.SetupRouter(baseLogger, mongoClient)

	log.Fatal(r.Run(fmt.Sprintf(":%d", environment.PORTA)))
}
