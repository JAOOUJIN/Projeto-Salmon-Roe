package router

import (
	"backend-app/internal/config/auth"
	env "backend-app/internal/config/environment"
	. "backend-app/internal/handlers"
	"backend-app/internal/middleware"
	. "backend-app/internal/repositories"
	"backend-app/internal/services/mail"
	"backend-app/internal/utils"
	"log/slog"
	"os"

	"github.com/gin-gonic/gin"
)

func SetupRouter(logger *slog.Logger) *gin.Engine {
	r := gin.New()
	gin.SetMode(gin.ReleaseMode)
	r.Use(
		middleware.CORS(),
		middleware.LoggerMiddleware(logger),
		gin.Recovery(),
	)
	cfg := env.LoadConfigureJWT()
	jwtManager := auth.NewJWTManager(cfg.JWTSecret, cfg.JWTExpiresIn)

	v1Group := r.Group(utils.UrlGroup)
	{
		authGroup := v1Group.Group(utils.AuthGroup)
		{
			registerAuth(jwtManager, authGroup)
			registerProduct(v1Group)
		}

		v1Group.Use(middleware.AuthRequired(jwtManager))
		{
			registerUser(v1Group)
			registerSales(v1Group)
		}
	}

	return r
}

func registerAuth(jwtManager *auth.JWTManager, group *gin.RouterGroup) {
	userRepo := NewUserRepository(os.Getenv("COLLECTION_NAME_USERS"))
	var mailer *mail.Sender
	if s, ok := mail.NewSenderFromEnv(); ok {
		mailer = s
	}
	NewAuthHandler(userRepo, jwtManager, mailer).GetDashboardRoutes(group)
}

func registerProduct(group *gin.RouterGroup) {
	repo := NewProductRepository(os.Getenv("COLLECTION_NAME_PRODUCTS"))
	NewProductController(repo).GetProductsRoutes(group)
}

func registerUser(group *gin.RouterGroup) {
	repo := NewUserRepository(os.Getenv("COLLECTION_NAME_USERS"))
	NewUserController(repo).GetUsersRoutes(group)
}

func registerSales(group *gin.RouterGroup) {
	salesRepo := NewSalesRepository(os.Getenv("COLLECTION_NAME_SALES"))
	productRepo := NewProductRepository(os.Getenv("COLLECTION_NAME_PRODUCTS"))
	NewSalesController(salesRepo, productRepo).GetSalesRoutes(group)
}
