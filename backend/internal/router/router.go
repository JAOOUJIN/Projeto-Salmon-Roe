package router

import (
	"backend-app/internal/config/auth"
	env "backend-app/internal/config/environment"
	. "backend-app/internal/handlers"
	"backend-app/internal/middleware"
	"backend-app/internal/notify"
	. "backend-app/internal/repositories"
	"backend-app/internal/services/mail"
	"backend-app/internal/utils"
	"context"
	"log/slog"
	"os"

	"github.com/gin-gonic/gin"
)

func SetupRouter(logger *slog.Logger) *gin.Engine {
	r := gin.New()
	r.Use(
		middleware.CORS(),
		middleware.LoggerMiddleware(logger),
		gin.Recovery(),
	)
	cfg := env.LoadConfigureJWT()
	jwtManager := auth.NewJWTManager(cfg.JWTSecret, cfg.JWTExpiresIn)

	userRepo := NewUserRepository(os.Getenv("COLLECTION_NAME_USERS"))
	hub := notify.NewHub()
	go hub.Run()

	fcmSender, err := notify.NewFCMSender(context.Background(), userRepo, logger)
	if err != nil {
		logger.Error("falha ao inicializar FCM", "error", err.Error())
	}
	notifier := &notify.Composite{Hub: hub, FCM: fcmSender}

	v1Group := r.Group(utils.UrlGroup)
	{
		authGroup := v1Group.Group(utils.AuthGroup)
		{
			registerAuth(jwtManager, authGroup, userRepo)
			registerProduct(v1Group)
		}

		v1Group.GET(utils.UserWebSocketURL, func(c *gin.Context) {
			notify.ServeWebSocket(c, jwtManager, hub)
		})

		v1Group.Use(middleware.AuthRequired(jwtManager))
		{
			registerUser(v1Group, userRepo)
			registerSales(v1Group, notifier)
		}
	}

	return r
}

func registerAuth(jwtManager *auth.JWTManager, group *gin.RouterGroup, userRepo *UserRepository) {
	var mailer mail.PasswordResetMailer
	if m, ok := mail.NewPasswordResetMailerFromEnv(); ok {
		mailer = m
	}
	NewAuthHandler(userRepo, jwtManager, mailer).GetDashboardRoutes(group)
}

func registerProduct(group *gin.RouterGroup) {
	repo := NewProductRepository(os.Getenv("COLLECTION_NAME_PRODUCTS"))
	NewProductController(repo).GetProductsRoutes(group)
}

func registerUser(group *gin.RouterGroup, userRepo *UserRepository) {
	NewUserController(userRepo).GetUsersRoutes(group)
}

func registerSales(group *gin.RouterGroup, notifier notify.OrderStatusNotifier) {
	salesRepo := NewSalesRepository(os.Getenv("COLLECTION_NAME_SALES"))
	productRepo := NewProductRepository(os.Getenv("COLLECTION_NAME_PRODUCTS"))
	userRepo := NewUserRepository(os.Getenv("COLLECTION_NAME_USERS"))
	NewSalesController(salesRepo, productRepo, userRepo, notifier).GetSalesRoutes(group)
}
