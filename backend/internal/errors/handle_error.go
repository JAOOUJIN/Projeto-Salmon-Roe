package errors

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

func HandleError(c *gin.Context, err error) {
	c.JSON(http.StatusBadRequest, ApiError{
		Error: err.Error(),
	})
}

func HandleErrorWithStatus(c *gin.Context, err *ApiError) {
	c.JSON(err.StatusCode, err)
}
