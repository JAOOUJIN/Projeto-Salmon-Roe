package utils

import "math"

func AroundFloat(valor float64) float64 {
	return math.Round(valor*100) / 100
}
