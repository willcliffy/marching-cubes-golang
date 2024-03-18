package main

type IntMarcher struct {
	params *MarchingCubesParams
	tables *MarchingCubesTables
	noise  *Noise3D

	cursor   Vector3i
	computed []Triangle
}

func NewIntMarcher(params *MarchingCubesParams, tables *MarchingCubesTables, noise *Noise3D) IntMarcher {
	return IntMarcher{
		params,
		tables,
		noise,
		Vector3i{},
		[]Triangle{},
	}
}

func (m *IntMarcher) March() bool {
	corners := []Vector4{
		m.evaluate(m.cursor.AddV3i(Vector3i{0, 0, 0})),
		m.evaluate(m.cursor.AddV3i(Vector3i{1, 0, 0})),
		m.evaluate(m.cursor.AddV3i(Vector3i{1, 0, 1})),
		m.evaluate(m.cursor.AddV3i(Vector3i{0, 0, 1})),
		m.evaluate(m.cursor.AddV3i(Vector3i{0, 1, 0})),
		m.evaluate(m.cursor.AddV3i(Vector3i{1, 1, 0})),
		m.evaluate(m.cursor.AddV3i(Vector3i{1, 1, 1})),
		m.evaluate(m.cursor.AddV3i(Vector3i{0, 1, 1})),
	}

	index := m.cubeIndexFromCorners(corners)
	offset := m.tables.Offsets[index]
	numIndices := m.tables.Lengths[index]

	for i := 0; i < numIndices; i += 3 {
		m.computed = append(m.computed, m.createTriangle(i, offset, corners))
	}

	return m.incrementCursor()
}

func (m IntMarcher) evaluate(pos Vector3i) Vector4 {
	return Vector4{
		float64(pos.X),
		float64(pos.Y),
		float64(pos.Z),
		m.noise.GetNoise(pos.X, pos.Y, pos.Z),
	}
}

func (m IntMarcher) cubeIndexFromCorners(corners []Vector4) int {
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

func (m IntMarcher) createTriangle(i int, offset int, corners []Vector4) Triangle {
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

func (m *IntMarcher) incrementCursor() bool {
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
