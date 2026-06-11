package handlers

import (
	erro "backend-app/internal/errors"
	"backend-app/internal/models"
	repo "backend-app/internal/repositories"
	"backend-app/internal/utils"
	"net/http"

	"github.com/gin-gonic/gin"
)

type ProductController struct {
	repo repo.ProductRepositoryInterface
}

type ProductControllerInterface interface {
	GetProductsRoutes(rGroup *gin.RouterGroup)
}

func NewProductController(service repo.ProductRepositoryInterface) *ProductController {
	return &ProductController{service}
}

func (p *ProductController) GetProductsRoutes(routerGroup *gin.RouterGroup) {
	routerGroup.GET(utils.ProductsGroup, p.GetAllProducts)
	routerGroup.GET(utils.GetProductByNameUrl, p.GetProductByName)
}

func (p *ProductController) GetAllProducts(c *gin.Context) {
	log := utils.LoggerFromContext(c.Request.Context())

	log.Debug("buscando lista de todos os produtos", utils.Function, utils.FnCallerName())

	resultList, errDB := p.repo.FindAll(c)
	if errDB != nil {
		log.Error(erro.ErrSqlException.Error(), utils.Function, utils.FnCallerName())
		erro.HandleError(c, erro.ErrInternalServer)
		return
	} else if len(resultList) <= 0 {
		c.JSON(http.StatusNoContent, resultList)
		return
	}

	c.JSON(http.StatusOK, ToDTO(resultList))
}

func (p *ProductController) GetProductByName(c *gin.Context) {
	log := utils.LoggerFromContext(c.Request.Context())

	// Obtém o parâmetro de query "name"
	name := c.Query("name")
	if name == "" {
		log.Error("parâmetro 'name' não fornecido", utils.Function, utils.FnCallerName())
		erro.HandleError(c, erro.ErrInvalidParams)
		return
	}

	log.Debug("buscando produtos por nome", utils.Function, utils.FnCallerName(), "name", name)

	resultList, errDB := p.repo.FindByName(c, name)
	if errDB != nil {
		log.Error(erro.ErrSqlException.Error(), utils.Function, utils.FnCallerName())
		erro.HandleError(c, erro.ErrInternalServer)
		return
	} else if len(resultList) <= 0 {
		c.JSON(http.StatusNoContent, resultList)
		return
	}

	c.JSON(http.StatusOK, ToDTO(resultList))
}

func ToDTO(product []models.ProductEntity) []models.ProductDTO {
	var resultDTO []models.ProductDTO

	for _, p := range product {
		resultDTO = append(resultDTO, models.ProductDTO{
			ID:                 p.ID,
			NameProduct:        p.NameProduct,
			ProductDescription: p.ProductDescription,
			ProductPrice:       p.ProductPrice,
			OldProductPrice:    p.OldProductPrice,
			IsHighlighted:      p.IsHighlighted,
			IsNew:              p.IsNew,
			Category:           p.Category,
			ProductImageUrl:    p.ProductImageUrl,
			Active:             p.Active,
		})
	}

	return resultDTO
}
