package main

type MarchingCubesParams struct {
	size          Vector3
	scale         float64
	voxelsPerAxis int
	isoLevel      float64
}

func (p MarchingCubesParams) sampleNoise(pos Vector3) float64 {
	if pos.X < p.size.X*0.05 || pos.X > p.size.X*0.95 {
		return 0.5
	} else if pos.Z < p.size.X*0.05 || pos.X > p.size.X*0.95 {
		return 0.5
	} else if pos.Y < p.size.Y*0.05 {
		return 0.5
	} else if pos.Y < p.size.Y*0.1 {
		return 1
	} else {
		return 0.5 * (noise.Noise3D(pos.X, pos.Y, pos.Z) + 1)
	}
}

func (m MarchingCubesParams) interpolateVerts(v1, v2 Vector4) Vector3 {
	t := (m.isoLevel - v1.W) / (v2.W - v1.W)

	// fmt.Printf("interp - t: %v\n\tv1: %v\n\tv2: %v\n\tv2.sub(v1): %v\n\tsubmul: %v\n\tsubmuladd: %v\n\ttv3: %v\n",
	// 	t,
	// 	v1,
	// 	v2,
	// 	v2.Sub(v1),
	// 	v2.Sub(v1).Mul(t),
	// 	v1.Add(v2.Sub(v1).Mul(t)),
	// 	v1.Add(v2.Sub(v1).Mul(t)).ToVector3(),
	// )

	return v1.Add(v2.Sub(v1).Mul(t)).ToVector3()
}
