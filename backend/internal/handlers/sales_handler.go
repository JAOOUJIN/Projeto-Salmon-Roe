package handlers

import (
	erro "backend-app/internal/errors"
	"backend-app/internal/models"
	"backend-app/internal/notify"
	repo "backend-app/internal/repositories"
	"backend-app/internal/utils"
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"math"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
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
	var response gin.H
	var req models.CreateSaleRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		log.Error("erro ao validar requisição", utils.Function, utils.FnCallerName(), "error", err.Error())
		erro.HandleError(c, erro.ErrInvalidParams)
		return
	}

	// Buscar produtos e validar existência
	var totalVenda int64
	var totalPrice float64
	var salesItems []models.SalesItem
	var itemsPagBank []map[string]interface{}
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

		valorCentavos := int64(math.Round(product.ProductPrice * 100))
		totalVenda += valorCentavos * itemReq.Quantity
		totalPrice += product.ProductPrice * float64(itemReq.Quantity)

		itemsPagBank = append(itemsPagBank, map[string]interface{}{
			"name":        productID,
			"quantity":    itemReq.Quantity,
			"unit_amount": valorCentavos,
		})

		salesItems = append(salesItems, models.SalesItem{
			ProductID: productID,
			Quantity:  float64(itemReq.Quantity),
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
		SalesValue: totalPrice,
		Status:     utils.StatusPending,
		Itens:      salesItems,
		Address:    req.Address,
		Delivery:   req.Delivery,
		Payment:    req.Payment,
	}

	isPix := strings.ToUpper(req.Payment) == "PIX"

	// Só gera Pix se o pagamento for exatamente "Pix"
	if isPix {
		PagBankURL := os.Getenv("PAGBANK_LINK")
		token := os.Getenv("PAGBANK_TOKEN_TEST")

		if token == "" {
			erro.HandleError(c, erro.ErrTokenPagBank)
			return
		}

		// 3. Montar o Payload no formato que o PagBank exige
		pagbankPayload := map[string]interface{}{
			"reference_id": req.SalesID,
			"customer": map[string]interface{}{
				"name":   user.Name,
				"email":  user.Email,
				"tax_id": user.CPF,
			},
			"items": itemsPagBank,
			"qr_codes": []map[string]interface{}{
				{
					"amount": map[string]interface{}{
						"value": totalVenda,
					},
					"expiration_date": time.Now().Add(10 * time.Second).Format(time.RFC3339),
				},
			},
		}

		jsonData, err := json.Marshal(pagbankPayload)
		if err != nil {
			erro.HandleError(c, erro.ErrBuildSale)
			return
		}

		// 4. Criar a requisição HTTP nativa do Go
		httpReq, err := http.NewRequestWithContext(c, "POST", PagBankURL, bytes.NewBuffer(jsonData))
		if err != nil {
			erro.HandleError(c, erro.ErrCreateHTTPRequest)
			return
		}

		httpReq.Header.Set("Authorization", "Bearer "+token)
		httpReq.Header.Set("Content-Type", "application/json")

		// 5. Executar a requisição
		client := &http.Client{Timeout: 10 * time.Minute}
		resp, err := client.Do(httpReq)
		if err != nil {
			erro.HandleError(c, erro.ErrPagBankConnection)
			return
		}
		defer resp.Body.Close()

		body, _ := io.ReadAll(resp.Body)

		if resp.StatusCode < 200 || resp.StatusCode >= 300 {
			erro.HandleError(c, erro.ErrPagBankRequestRefused)
			return
		}

		// 6. Fazer o parse dinâmico da resposta do PagBank
		var pagBankResponse map[string]interface{}
		_ = json.Unmarshal(body, &pagBankResponse)

		orderID := pagBankResponse["id"]

		var qrCodeText, qrCodeLink string
		if qrCodes, ok := pagBankResponse["qr_codes"].([]interface{}); ok && len(qrCodes) > 0 {
			if firstQR, ok := qrCodes[0].(map[string]interface{}); ok {
				qrCodeText, _ = firstQR["text"].(string)

				if links, ok := firstQR["links"].([]interface{}); ok && len(links) > 0 {
					if firstLink, ok := links[0].(map[string]interface{}); ok {
						qrCodeLink, _ = firstLink["href"].(string)
					}
				}
			}
		}

		response = gin.H{
			"status":         "success",
			"payment_id":     orderID,
			"qr_code":        qrCodeText,
			"qr_code_base64": qrCodeLink,
			"message":        "Venda com Pix criada!",
			"sale":           s.populateProducts(c, *newSale),
		}
	}

	if len(response) == 0 {
		response = gin.H{
			"status":  "success",
			"message": "Pedido realizado! Pague ao receber",
			"sale":    s.populateProducts(c, *newSale),
		}
	}

	// Salva o documento da venda inicial como 'pending' no MongoDB Atlas
	if err := s.salesRepo.Create(c, newSale); err != nil {
		log.Error("erro ao criar venda", utils.Function, utils.FnCallerName(), "error", err.Error())
		erro.HandleError(c, erro.ErrInternalServer)
		return
	}

	// AUTO-CANCELAMENTO
	if isPix {
		saleIDParaTimeout := newSale.ID

		time.AfterFunc(10*time.Minute, func() {
			// 1. Cria o MESMO contexto isolado do seu endpoint oficial
			ctxBg, cancelBg := context.WithTimeout(context.Background(), 8*time.Second)
			defer cancelBg()

			// 2. Busca para ter certeza de que o cliente já não pagou nesses 30s
			vendaAtual, errFetch := s.salesRepo.FindByID(ctxBg, saleIDParaTimeout)
			if errFetch != nil || vendaAtual == nil {
				return
			}

			// 3. Se continua pendente, executamos a mesma regra de negócio do UpdateSaleStatus
			if vendaAtual.Status == utils.StatusPending {
				log.Info("[TIMER] Tempo do Pix expirou. Cancelando pedido...", "saleId", saleIDParaTimeout.Hex())

				// Executa a atualização no banco de dados
				saleCancelada, errDB := s.salesRepo.UpdateStatus(ctxBg, saleIDParaTimeout, "cancelled")
				if errDB != nil {
					log.Error("[TIMER] Erro ao atualizar status pelo timer", "error", errDB.Error())
					return
				}

				time.Sleep(1 * time.Second)

				// 4. Se o banco atualizou, dispara o WebSocket/FCM IGUAL ao endpoint
				if saleCancelada != nil && s.notifier != nil && !saleCancelada.UserID.IsZero() {
					log.Info("[TIMER] Disparando WebSocket de cancelamento...")

					// Usa os dados que acabaram de voltar fresquinhos do banco de dados
					s.notifier.NotifyOrderStatus(ctxBg, saleCancelada.UserID, saleCancelada.ID, saleCancelada.SalesID, saleCancelada.Status)

					log.Info("[TIMER] Cancelamento e notificação concluídos!")
				}
			}
		})
	}

	log.Debug("venda criada com sucesso", utils.Function, utils.FnCallerName())
	c.JSON(http.StatusCreated, response)
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
