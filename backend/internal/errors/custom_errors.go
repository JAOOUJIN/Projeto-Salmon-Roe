package errors

import "errors"

var (
	ErrInvalidParams  = errors.New("parâmetros da requisição inválidos")
	ErrInternalServer = errors.New("erro interno do servidor")
	ErrSqlException   = errors.New("erro na consulta de banco de dados")
	ErrEmptyResult    = errors.New("nenhum resultado encontrado")
)

type ApiError struct {
	Error      string
	StatusCode int `json:"statusCode"`
}
