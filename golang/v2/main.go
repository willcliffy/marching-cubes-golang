package main

import (
	"encoding/json"
	"os"
)

func main() {
	params := &MarchingCubesParams{
		size:       Vector3i{X: 100, Y: 10, Z: 100},
		scale:      1.0,
		isoLevel:   0.5,
		resolution: 0.05,
	}

	tables, err := LoadTables("tables.json")
	if err != nil {
		panic(err)
	}

	noiseGen := NewNoiseGenerator(params.size, params.resolution)

	marcher := NewIntMarcher(params, tables, noiseGen.GenerateNoise())

	for !marcher.March() {
	}

	// for _, computed := range marcher.computed {
	// 	//fmt.Printf("%v\n", computed)
	// }

	bytes, err := json.Marshal(marcher.computed)
	if err != nil {
		panic(err)
	}

	err = os.WriteFile("../../godot/v2/out.json", bytes, 0644)
	if err != nil {
		panic(err)
	}
}
