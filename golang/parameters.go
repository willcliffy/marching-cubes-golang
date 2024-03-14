package main

type MarchingCubesParams struct {
	size       Vector3
	scale      float64
	isoLevel   float64
	resolution float64
}

func (p MarchingCubesParams) sampleNoise(pos Vector3) float64 {
	var sample float64

	if pos.X < p.size.X*0.05 || pos.X > p.size.X*0.95 {
		sample = 0.0
	} else if pos.Z < p.size.Z*0.05 || pos.Z > p.size.Z*0.95 {
		sample = 0.0
	} else if pos.Y < p.size.Y*0.05 {
		sample = 0.0
	} else if pos.Y < p.size.Y*0.1 {
		sample = 1.0
	} else {
		sample = noise.Noise3D(pos.X, pos.Y, pos.Z)
	}

	return 0.5 * (sample + 1.0)
}

func (m MarchingCubesParams) interpolateVerts(v1, v2 Vector4) Vector3 {
	t := (m.isoLevel - v1.W) / (v2.W - v1.W)
	return v1.Add(v2.Sub(v1).Mul(t)).ToVector3()
}
