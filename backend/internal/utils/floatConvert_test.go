package utils

import "testing"

func TestAroundFloat(t *testing.T) {
	tests := []struct {
		in   float64
		want float64
	}{
		{0, 0},
		{1, 1},
		{1.004, 1},
		// 1.005 arredonda para 1 em IEEE754 (1.005*100 não é exatamente 100,5).
		{1.235, 1.24},
		{10.125, 10.13},
		{-3.456, -3.46},
		{0.001, 0},
		{0.015, 0.02},
	}
	for _, tt := range tests {
		got := AroundFloat(tt.in)
		if got != tt.want {
			t.Errorf("AroundFloat(%g) = %g; want %g", tt.in, got, tt.want)
		}
	}
}
