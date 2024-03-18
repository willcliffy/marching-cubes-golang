package main

import (
	"github.com/aquilax/go-perlin"
)

const (
	PerlinAlpha float64 = 2.0
	PerlinBeta  float64 = 3.0
	PerlinN     int32   = 2
	PerlinSeed  int64   = 0
)

var _noise = perlin.NewPerlin(PerlinAlpha, PerlinBeta, PerlinN, PerlinSeed)

type Noise3D struct {
	data [][][]float64
	size Vector3i
}

func NewNoise3D(data [][][]float64, size Vector3i) *Noise3D {
	return &Noise3D{
		data,
		size,
	}
}

func (n Noise3D) GetNoise(x, y, z int) float64 {
	if y < 1 {
		return 1.0
	} else if y >= n.size.Y || x <= 0 || z <= 0 || x >= n.size.X || z >= n.size.Z {
		return 0.0
	}

	return n.data[y][x][z]
}

type Noiser struct {
	Size       Vector3i
	Resolution float64
}

func NewNoiseGenerator(size Vector3i, res float64) *Noiser {
	return &Noiser{size, res}
}

func (n Noiser) GenerateNoise() *Noise3D {
	data := make([][][]float64, n.Size.Y)

	// make the middle row first
	yMiddle := int(float64(n.Size.Y) / 2.0)

	for y := range n.Size.Y {
		data[y] = make([][]float64, n.Size.X)
		for x := range n.Size.X {
			data[y][x] = make([]float64, n.Size.Z)
		}
	}

	for x := range n.Size.X {
		for z := range n.Size.Z {
			data[yMiddle][x][z] = (_noise.Noise3D(float64(x)*n.Resolution, float64(yMiddle)*n.Resolution, float64(z)*n.Resolution) + 1.0) / 2.0
		}
	}

	for y := yMiddle - 1; y >= 0; y-- {
		for x := range n.Size.X {
			for z := range n.Size.Z {
				data[y][x][z] = data[y+1][x][z] * 1.1
			}
		}
	}

	for y := yMiddle + 1; y < n.Size.Y; y++ {
		for x := range n.Size.X {
			for z := range n.Size.Z {
				data[y][x][z] = data[y-1][x][z] * 0.9
			}
		}
	}

	return NewNoise3D(data, n.Size)
}
