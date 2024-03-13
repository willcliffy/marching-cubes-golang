package main

import (
	"encoding/json"
	"os"
)

type MarchingCubesTables struct {
	Offsets []int `json:"offsets"`
	Lengths []int `json:"lengths"`
	CornerA []int `json:"cornerA"`
	CornerB []int `json:"cornerB"`
	Lookup  []int `json:"lookup"`
}

func LoadTables(filename string) (*MarchingCubesTables, error) {
	fileContents, err := os.ReadFile(filename)
	if err != nil {
		return nil, err
	}

	var tables MarchingCubesTables
	err = json.Unmarshal(fileContents, &tables)
	if err != nil {
		return nil, err
	}

	return &tables, nil
}
