package main

import (
	"math"
)

type Marcher struct {
	params *MarchingCubesParams
	tables *MarchingCubesTables

	cursor   Vector3
	computed []Triangle
}

func NewMarcher(params *MarchingCubesParams, tables *MarchingCubesTables) Marcher {
	return Marcher{
		params,
		tables,
		Vector3{},
		[]Triangle{},
	}
}

func (m *Marcher) March() bool {
	corners := []Vector4{
		m.evaluate(m.cursor.Add(Vector3{0, 0, 0})),
		m.evaluate(m.cursor.Add(Vector3{1, 0, 0})),
		m.evaluate(m.cursor.Add(Vector3{1, 0, 1})),
		m.evaluate(m.cursor.Add(Vector3{0, 0, 1})),
		m.evaluate(m.cursor.Add(Vector3{0, 1, 0})),
		m.evaluate(m.cursor.Add(Vector3{1, 1, 0})),
		m.evaluate(m.cursor.Add(Vector3{1, 1, 1})),
		m.evaluate(m.cursor.Add(Vector3{0, 1, 1})),
	}

	index := m.cubeIndexFromCorners(corners)
	offset := m.tables.Offsets[index]
	numIndices := m.tables.Lengths[index]

	for i := 0; i < numIndices; i += 3 {
		m.computed = append(m.computed, m.createTriangle(i, offset, corners))
	}

	return m.incrementCursor()
}

func (m Marcher) evaluate(pos Vector3) Vector4 {
	cellSize := m.params.resolution * m.params.scale
	centerSnapped := Vector3{
		X: cellSize * math.Floor(pos.X/cellSize+0.5*sign(pos.X)),
		Y: cellSize * math.Floor(pos.Y/cellSize+0.5*sign(pos.Y)),
		Z: cellSize * math.Floor(pos.Z/cellSize+0.5*sign(pos.Z)),
	}

	positionNorm := pos.Mul(m.params.resolution).Mul(m.params.scale)
	worldPosition := positionNorm.Add(centerSnapped)

	density := m.params.sampleNoise(worldPosition)

	return Vector4{
		worldPosition.X,
		worldPosition.Y,
		worldPosition.Z,
		density,
	}
}

func sign(input float64) float64 {
	if input > 0 {
		return 1
	} else if input < 0 {
		return -1
	} else {
		return 0
	}
}

func (m Marcher) cubeIndexFromCorners(corners []Vector4) int {
	index := int(0)
	if corners[0].W < m.params.isoLevel {
		index += 1
	}
	if corners[1].W < m.params.isoLevel {
		index += 2
	}
	if corners[2].W < m.params.isoLevel {
		index += 4
	}
	if corners[3].W < m.params.isoLevel {
		index += 8
	}
	if corners[4].W < m.params.isoLevel {
		index += 16
	}
	if corners[5].W < m.params.isoLevel {
		index += 32
	}
	if corners[6].W < m.params.isoLevel {
		index += 64
	}
	if corners[7].W < m.params.isoLevel {
		index += 128
	}
	return index
}

func (m Marcher) createTriangle(i int, offset int, corners []Vector4) Triangle {
	v0 := m.tables.Lookup[offset+i+0]
	v1 := m.tables.Lookup[offset+i+1]
	v2 := m.tables.Lookup[offset+i+2]

	a0 := m.tables.CornerA[v0]
	b0 := m.tables.CornerB[v0]

	a1 := m.tables.CornerA[v1]
	b1 := m.tables.CornerB[v1]

	a2 := m.tables.CornerA[v2]
	b2 := m.tables.CornerB[v2]

	// Calculate vertex positions
	A := m.params.interpolateVerts(corners[a0], corners[b0])
	B := m.params.interpolateVerts(corners[a1], corners[b1])
	C := m.params.interpolateVerts(corners[a2], corners[b2])

	AB := B.Sub(A)
	AC := C.Sub(A)

	Normal := AC.Cross(AB).Normalized()

	triangle := Triangle{A, B, C, Normal}

	return triangle
}

func (m *Marcher) incrementCursor() bool {
	m.cursor.X += 1
	if m.cursor.X >= m.params.size.X {
		m.cursor.X = 0
		m.cursor.Z += 1
		if m.cursor.Z >= m.params.size.Z {
			m.cursor.Z = 0
			m.cursor.Y += 1
			return m.cursor.Y >= m.params.size.Y
		}
	}

	return false
}
