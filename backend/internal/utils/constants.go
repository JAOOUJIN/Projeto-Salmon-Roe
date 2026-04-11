package utils

// URLS
const (
	//group
	UrlGroup = "/v1/api/salmon_roe"
	//auth
	AuthGroup         = "/auth"
	LoginURL          = "/login"
	ForgotPasswordURL = "/forgot-password"
	ResetPasswordURL  = "/reset-password"

	//user
	UserGroup           = "/user"
	UserRegisterURL     = UserGroup + "/register"
	UserUpdateInfoURL   = UserGroup + "/update-info"
	UserUpdateAccessURL = UserGroup + "/update-access"

	//address
	AddressGroup              = UserGroup + "/address"
	AddressRegisterURL        = AddressGroup
	AddressUpdateURL          = AddressGroup + "/:address-id"
	AddressDeleteURL          = AddressUpdateURL
	AddressRegisterDefaultURL = AddressGroup + "/set-default-address/:address-id"

	//products
	ProductsGroup       = "/products"
	GetProductByNameUrl = "/products/search"

	//sales
	SalesGroup            = "/sales"
	CreateSaleURL         = SalesGroup
	GetAllSalesURL        = SalesGroup
	GetSaleByIdURL        = SalesGroup + "/:id"
	GetUserSalesURL       = SalesGroup + "/my-orders"
	GetLastOrderStatusURL = SalesGroup + "/last-order-status"
)

const (
	JWTExpiresHours     = 24
	TimeZoneSP          = "America/Sao_Paulo"
	ForgotPasswordOkMsg = "Se o e-mail estiver cadastrado, você receberá um código em instantes."
)

// status sales
const (
	StatusPending   = "pending"
	StatusConfirmed = "confirmed"
	StatusShipped   = "shipped"
	StatusOnTheWay  = "on_the_way"
	StatusDelivered = "delivered"
	StatusCancelled = "cancelled"
)
