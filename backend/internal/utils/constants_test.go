package utils

import (
	"strings"
	"testing"
)

func TestIsValidSaleStatus_Valid(t *testing.T) {
	for _, s := range ValidSaleStatuses {
		if !IsValidSaleStatus(s) {
			t.Errorf("expected valid: %q", s)
		}
	}
}

func TestIsValidSaleStatus_Invalid(t *testing.T) {
	for _, s := range []string{"", "PENDING", "unknown", "pending "} {
		if IsValidSaleStatus(s) {
			t.Errorf("expected invalid: %q", s)
		}
	}
}

func TestConstants_URLPaths(t *testing.T) {
	if !strings.HasPrefix(UserRegisterURL, UserGroup) {
		t.Fatalf("UserRegisterURL=%q UserGroup=%q", UserRegisterURL, UserGroup)
	}
	if !strings.Contains(GetSaleByIdURL, ":id") {
		t.Fatalf("GetSaleByIdURL=%q", GetSaleByIdURL)
	}
	if ForgotPasswordOkMsg == "" {
		t.Fatal("ForgotPasswordOkMsg empty")
	}
	if UrlGroup == "" {
		t.Fatal("UrlGroup empty")
	}
}

func TestConstants_StatusStrings(t *testing.T) {
	if StatusPending != "pending" || StatusDelivered != "delivered" {
		t.Fatalf("status constants changed: %s %s", StatusPending, StatusDelivered)
	}
	if len(ValidSaleStatuses) != 6 {
		t.Fatalf("ValidSaleStatuses len=%d", len(ValidSaleStatuses))
	}
}
