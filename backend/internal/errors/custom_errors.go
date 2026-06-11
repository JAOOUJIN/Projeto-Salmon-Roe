package errors

import "errors"

var (
	ErrInvalidParams         = errors.New("parâmetros da requisição inválidos")
	ErrInternalServer        = errors.New("erro interno do servidor")
	ErrSqlException          = errors.New("erro na consulta de banco de dados")
	ErrEmptyResult           = errors.New("nenhum resultado encontrado")
	ErrTokenPagBank          = errors.New("error variável de ambiente PAGBANK_TOKEN não está definida")
	ErrBuildSale             = errors.New("erro ao montar a venda")
	ErrCreateHTTPRequest     = errors.New("erro ao criar requisição HTTP")
	ErrPagBankConnection     = errors.New("erro ao conectar com o PagBank")
	ErrPagBankRequestRefused = errors.New("erro ao conectar com o PagBank, recusou pedido")
)

type ApiError struct {
	Error      string
	StatusCode int `json:"statusCode"`
}
