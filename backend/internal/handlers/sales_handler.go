package handlers

import (
	erro "backend-app/internal/errors"
	"backend-app/internal/models"
	"backend-app/internal/notify"
	repo "backend-app/internal/repositories"
	"backend-app/internal/utils"
	"context"
	"fmt"
	"net/http"
	"os"
	"time"

	"github.com/gin-gonic/gin"
	configMP "github.com/mercadopago/sdk-go/pkg/config"
	"github.com/mercadopago/sdk-go/pkg/payment"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

type SalesController struct {
	salesRepo   repo.SalesRepositoryInterface
	productRepo repo.ProductRepositoryInterface
	userRepo    repo.UserRepositoryInterface
	notifier    notify.OrderStatusNotifier
}

type SalesControllerInterface interface {
	GetSalesRoutes(rGroup *gin.RouterGroup)
}

func NewSalesController(salesRepo repo.SalesRepositoryInterface,
	productRepo repo.ProductRepositoryInterface,
	userRepo repo.UserRepositoryInterface,
	n notify.OrderStatusNotifier) *SalesController {
	return &SalesController{
		salesRepo:   salesRepo,
		productRepo: productRepo,
		userRepo:    userRepo,
		notifier:    n,
	}
}

func (s *SalesController) GetSalesRoutes(routerGroup *gin.RouterGroup) {
	routerGroup.POST(utils.CreateSaleURL, s.CreateSale)
	routerGroup.GET(utils.GetAllSalesURL, s.GetSales)
	routerGroup.GET(utils.GetSaleByIdURL, s.GetSaleById)
	routerGroup.GET(utils.GetUserSalesURL, s.GetUserSales)
	routerGroup.GET(utils.GetLastOrderStatusURL, s.GetLastOrderStatus)
	routerGroup.PUT(utils.UpdateSaleStatusURL, s.UpdateSaleStatus)
}

func (s *SalesController) CreateSale(c *gin.Context) {
	log := utils.LoggerFromContext(c.Request.Context())
	log.Debug("criando nova venda", utils.Function, utils.FnCallerName())

	var req models.CreateSaleRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		log.Error("erro ao validar requisição", utils.Function, utils.FnCallerName(), "error", err.Error())
		erro.HandleError(c, erro.ErrInvalidParams)
		return
	}

	// Buscar produtos e validar existência
	var totalVenda float64
	var salesItems []models.SalesItem
	for _, itemReq := range req.Itens {
		productID, err := primitive.ObjectIDFromHex(itemReq.ProductID)
		if err != nil {
			log.Error("ID de produto inválido", utils.Function, utils.FnCallerName(), "productId", itemReq.ProductID)
			c.JSON(http.StatusBadRequest, gin.H{
				"error": fmt.Sprintf("ID de produto inválido: %s", itemReq.ProductID),
			})
			return
		}

		product, err := s.productRepo.FindByID(c, productID)
		if err != nil {
			log.Error("erro ao buscar produto", utils.Function, utils.FnCallerName(), "error", err.Error())
			erro.HandleError(c, erro.ErrInternalServer)
			return
		}

		if product == nil {
			log.Error("produto não encontrado", utils.Function, utils.FnCallerName(), "productId", itemReq.ProductID)
			c.JSON(http.StatusBadRequest, gin.H{
				"error": fmt.Sprintf("Produto %s não encontrado", itemReq.ProductID),
			})
			return
		}

		totalVenda += product.ProductPrice * itemReq.Quantity

		salesItems = append(salesItems, models.SalesItem{
			ProductID: productID,
			Quantity:  itemReq.Quantity,
			UnitPrice: product.ProductPrice,
		})
	}

	var userID primitive.ObjectID
	if userIdStr, exists := c.Get("userId"); exists {
		if userIdStr != nil {
			userID, _ = primitive.ObjectIDFromHex(userIdStr.(string))
		}
	}

	// 2. Buscar usuário no Banco
	user, err := s.userRepo.GetByID(userID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Usuário não encontrado"})
		return
	}

	newSale := &models.Sales{
		UserID:     userID,
		SalesID:    req.SalesID,
		SalesValue: totalVenda,
		Status:     utils.StatusPending,
		Itens:      salesItems,
		Address:    req.Address,
		Delivery:   req.Delivery,
		Payment:    req.Payment,
	}

	accessToken := os.Getenv("MP_ACCESS_TOKEN")
	if accessToken == "" {
		log.Error("Erro: Variável de ambiente MP_ACCESS_TOKEN não está definida.")
		c.JSON(http.StatusBadRequest, gin.H{
			"error": fmt.Sprintf("error ao acessar conta MP "),
		})
		return
	}

	cfg, err := configMP.New(accessToken)
	if err != nil {
		log.Error("Erro ao configurar o SDK do Mercado Pago: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{
			"error": fmt.Sprintf("Erro ao configurar o SDK do Mercado Pago"),
		})
		return
	}

	paymentClient := payment.NewClient(cfg)

	payRequest := payment.Request{
		TransactionAmount: utils.AroundFloat(totalVenda),
		Description:       fmt.Sprintf("venda:%d", req.SalesID),
		PaymentMethodID:   "pix",
		Payer: &payment.PayerRequest{
			Email: user.Email,
		},
	}
	if err := s.salesRepo.Create(c, newSale); err != nil {
		log.Error("erro ao criar venda", utils.Function, utils.FnCallerName(), "error", err.Error())
		erro.HandleError(c, erro.ErrInternalServer)
		return
	}
	resource, err := paymentClient.Create(c.Request.Context(), payRequest)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Falha ao gerar o Pix: " + err.Error()})
		return
	}

	log.Debug("venda criada com sucesso", utils.Function, utils.FnCallerName(), "saleId", newSale.ID.Hex())

	saleDTO := s.populateProducts(c, *newSale)
	pixData := resource.PointOfInteraction.TransactionData

	// Validamos se o QRCode foi gerado pela API (se a string não está vazia)
	if pixData.QRCode == "" {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Dados do Pix não retornados pela API"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"status":         "success",
		"payment_id":     resource.ID,
		"qr_code":        pixData.QRCode,
		"qr_code_base64": pixData.QRCodeBase64,
		"message":        "Venda criada!",
		"sale":           saleDTO,
	})
}

func (s *SalesController) GetSales(c *gin.Context) {
	log := utils.LoggerFromContext(c.Request.Context())
	log.Debug("buscando lista de todas as vendas", utils.Function, utils.FnCallerName())

	sales, errDB := s.salesRepo.FindAll(c)
	if errDB != nil {
		log.Error(erro.ErrSqlException.Error(), utils.Function, utils.FnCallerName())
		erro.HandleError(c, erro.ErrInternalServer)
		return
	}

	if len(sales) <= 0 {
		erro.HandleError(c, erro.ErrEmptyResult)
		c.JSON(http.StatusNoContent, []models.SalesDTO{})
		return
	}

	salesDTO := make([]models.SalesDTO, 0, len(sales))
	for _, sale := range sales {
		populatedSale := s.populateProducts(c, sale)
		salesDTO = append(salesDTO, populatedSale)
	}

	c.JSON(http.StatusOK, salesDTO)
}

func (s *SalesController) GetSaleById(c *gin.Context) {
	log := utils.LoggerFromContext(c.Request.Context())

	idParam := c.Param("id")
	saleID, err := primitive.ObjectIDFromHex(idParam)
	if err != nil {
		log.Error("ID de venda inválido", utils.Function, utils.FnCallerName(), "id", idParam)
		erro.HandleError(c, erro.ErrInvalidParams)
		return
	}

	log.Debug("buscando venda por ID", utils.Function, utils.FnCallerName(), "saleId", idParam)

	sale, errDB := s.salesRepo.FindByID(c, saleID)
	if errDB != nil {
		log.Error(erro.ErrSqlException.Error(), utils.Function, utils.FnCallerName())
		erro.HandleError(c, erro.ErrInternalServer)
		return
	}

	if sale == nil {
		log.Error("venda não encontrada", utils.Function, utils.FnCallerName(), "saleId", idParam)
		c.JSON(http.StatusNotFound, gin.H{
			"error": "Venda não encontrada.",
		})
		return
	}

	populatedSale := s.populateProducts(c, *sale)
	c.JSON(http.StatusOK, populatedSale)
}

// populateProducts busca os produtos e popula os dados completos
func (s *SalesController) populateProducts(c *gin.Context, sale models.Sales) models.SalesDTO {
	itemsDTO := make([]models.SalesItemDTO, 0, len(sale.Itens))

	for _, item := range sale.Itens {
		product, err := s.productRepo.FindByID(c, item.ProductID)
		if err != nil || product == nil {
			// Se não encontrar o produto, ainda retorna o item sem dados do produto
			itemsDTO = append(itemsDTO, models.SalesItemDTO{
				ProductID: item.ProductID.Hex(),
				Quantity:  item.Quantity,
				UnitPrice: item.UnitPrice,
			})
			continue
		}

		itemsDTO = append(itemsDTO, models.SalesItemDTO{
			ProductID: item.ProductID.Hex(),
			Quantity:  item.Quantity,
			Product: models.ProductDTO{
				ID:                 product.ID,
				NameProduct:        product.NameProduct,
				ProductDescription: product.ProductDescription,
				ProductPrice:       item.UnitPrice,
				OldProductPrice:    product.OldProductPrice,
				IsHighlighted:      product.IsHighlighted,
				IsNew:              product.IsNew,
				ProductImageUrl:    product.ProductImageUrl,
			},
		})
	}

	saleDTO := models.SalesDTO{
		ID:         sale.ID.Hex(),
		SalesID:    sale.SalesID,
		SalesValue: sale.SalesValue,
		Status:     sale.Status,
		Itens:      itemsDTO,
		CreatedAt:  sale.CreatedAt,
		UpdatedAt:  sale.UpdatedAt,
		Address:    sale.Address,
		Delivery:   sale.Delivery,
		Payment:    sale.Payment,
	}

	if !sale.UserID.IsZero() {
		saleDTO.UserID = sale.UserID.Hex()
	}

	return saleDTO
}

// GetUserSales lista todos os pedidos do usuário autenticado
func (s *SalesController) GetUserSales(c *gin.Context) {
	log := utils.LoggerFromContext(c.Request.Context())

	userIdStr, exists := c.Get("userId")
	if !exists || userIdStr == nil {
		log.Error("usuário não autenticado", utils.Function, utils.FnCallerName())
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "Usuário não autenticado",
		})
		return
	}

	userID, err := primitive.ObjectIDFromHex(userIdStr.(string))
	if err != nil {
		log.Error("ID de usuário inválido", utils.Function, utils.FnCallerName(), "userId", userIdStr)
		erro.HandleError(c, erro.ErrInvalidParams)
		return
	}

	log.Debug("buscando pedidos do usuário", utils.Function, utils.FnCallerName(), "userId", userID.Hex())

	sales, errDB := s.salesRepo.FindByUserID(c, userID)
	if errDB != nil {
		log.Error(erro.ErrSqlException.Error(), utils.Function, utils.FnCallerName(), "error", errDB.Error())
		erro.HandleError(c, erro.ErrInternalServer)
		return
	}

	if len(sales) <= 0 {
		erro.HandleError(c, erro.ErrEmptyResult)
		c.JSON(http.StatusNoContent, []models.SalesDTO{})
		return
	}

	salesDTO := make([]models.SalesDTO, 0, len(sales))
	for _, sale := range sales {
		populatedSale := s.populateProducts(c, sale)
		salesDTO = append(salesDTO, populatedSale)
	}

	c.JSON(http.StatusOK, salesDTO)
}

// GetLastOrderStatus retorna o status do último pedido feito pelo usuário autenticado
func (s *SalesController) GetLastOrderStatus(c *gin.Context) {
	log := utils.LoggerFromContext(c.Request.Context())

	userIdStr, exists := c.Get("userId")
	if !exists || userIdStr == nil {
		log.Error("usuário não autenticado", utils.Function, utils.FnCallerName())
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "Usuário não autenticado",
		})
		return
	}

	userID, err := primitive.ObjectIDFromHex(userIdStr.(string))
	if err != nil {
		log.Error("ID de usuário inválido", utils.Function, utils.FnCallerName(), "userId", userIdStr)
		erro.HandleError(c, erro.ErrInvalidParams)
		return
	}

	log.Debug("buscando último pedido do usuário", utils.Function, utils.FnCallerName(), "userId", userID.Hex())

	lastSale, errDB := s.salesRepo.FindLastByUserID(c, userID)
	if errDB != nil {
		log.Error(erro.ErrSqlException.Error(), utils.Function, utils.FnCallerName(), "error", errDB.Error())
		erro.HandleError(c, erro.ErrInternalServer)
		return
	}

	if lastSale == nil {
		log.Debug("nenhum pedido encontrado para o usuário", utils.Function, utils.FnCallerName(), "userId", userID.Hex())
		c.JSON(http.StatusNotFound, gin.H{
			"error":   "Nenhum pedido encontrado",
			"message": "Você ainda não possui pedidos cadastrados",
		})
		return
	}

	populatedSale := s.populateProducts(c, *lastSale)

	statusDTO := models.OrderStatusDTO{
		ID:         populatedSale.ID,
		Status:     populatedSale.Status,
		SalesValue: populatedSale.SalesValue,
		SalesID:    populatedSale.SalesID,
		CreatedAt:  populatedSale.CreatedAt,
		UpdatedAt:  populatedSale.UpdatedAt,
		Itens:      populatedSale.Itens,
		Address:    populatedSale.Address,
		Delivery:   populatedSale.Delivery,
		Payment:    populatedSale.Payment,
	}

	c.JSON(http.StatusOK, statusDTO)
}

// UpdateSaleStatus atualiza o status da venda e notifica o cliente (WebSocket + FCM).
// Opcional: ORDER_STATUS_UPDATE_SECRET — se definido, exige header X-Order-Status-Secret com o mesmo valor (painel/admin).
func (s *SalesController) UpdateSaleStatus(c *gin.Context) {
	log := utils.LoggerFromContext(c.Request.Context())

	if secret := os.Getenv("ORDER_STATUS_UPDATE_SECRET"); secret != "" {
		if c.GetHeader("X-Order-Status-Secret") != secret {
			c.JSON(http.StatusForbidden, gin.H{"error": "não autorizado a atualizar status"})
			return
		}
	}

	idParam := c.Param("id")
	saleID, err := primitive.ObjectIDFromHex(idParam)
	if err != nil {
		log.Error("ID de venda inválido", utils.Function, utils.FnCallerName(), "id", idParam)
		erro.HandleError(c, erro.ErrInvalidParams)
		return
	}

	var req models.UpdateSaleStatusRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	if !utils.IsValidSaleStatus(req.Status) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "status inválido"})
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 8*time.Second)
	defer cancel()

	sale, errDB := s.salesRepo.UpdateStatus(ctx, saleID, req.Status)
	if errDB != nil {
		log.Error("erro ao atualizar status", utils.Function, utils.FnCallerName(), "error", errDB.Error())
		erro.HandleError(c, erro.ErrInternalServer)
		return
	}
	if sale == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Venda não encontrada"})
		return
	}

	if s.notifier != nil && !sale.UserID.IsZero() {
		s.notifier.NotifyOrderStatus(ctx, sale.UserID, sale.ID, sale.SalesID, sale.Status)
	}

	populated := s.populateProducts(c, *sale)
	c.JSON(http.StatusOK, gin.H{
		"message": "Status atualizado",
		"sale":    populated,
	})
}
