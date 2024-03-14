package main

import (
	"encoding/json"
	"os"

	"github.com/aquilax/go-perlin"
)

const (
	PerlinAlpha float64 = 2.0
	PerlinBeta  float64 = 2.0
	PerlinN     int32   = 2
	PerlinSeed  int64   = 0
)

var noise = perlin.NewPerlin(PerlinAlpha, PerlinBeta, PerlinN, PerlinSeed)

func main() {
	params := MarchingCubesParams{
		size:       Vector3{X: 20, Y: 5, Z: 20},
		scale:      1.0,
		isoLevel:   0.5,
		resolution: 1.0 / 64.0,
	}

	tables, err := LoadTables("tables.json")
	if err != nil {
		panic(err)
	}

	marcher := NewMarcher(&params, tables)

	for !marcher.March() {
	}

	// for _, computed := range marcher.computed {
	// 	//fmt.Printf("%v\n", computed)
	// }

	bytes, err := json.Marshal(marcher.computed)
	if err != nil {
		panic(err)
	}

	err = os.WriteFile("../godot/out.json", bytes, 0644)
	if err != nil {
		panic(err)
	}
}
