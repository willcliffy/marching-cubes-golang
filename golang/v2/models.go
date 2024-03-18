package main

import "math"

// Vector3

type Vector3 struct {
	X, Y, Z float64
}

func (v Vector3) Mul(factor float64) Vector3 {
	return Vector3{
		v.X * factor,
		v.Y * factor,
		v.Z * factor,
	}
}

func (v Vector3) Div(divisor float64) Vector3 {
	return Vector3{
		v.X / divisor,
		v.Y / divisor,
		v.Z / divisor,
	}
}

func (v Vector3) Cross(factor Vector3) Vector3 {
	return Vector3{
		v.Y*factor.Z - v.Z*factor.Y,
		v.Z*factor.X - v.X*factor.Z,
		v.X*factor.Y - v.Y*factor.X,
	}
}

func (v Vector3) Add(addend Vector3) Vector3 {
	return Vector3{
		v.X + addend.X,
		v.Y + addend.Y,
		v.Z + addend.Z,
	}
}

func (v Vector3) Sub(subtrahend Vector3) Vector3 {
	return Vector3{
		v.X - subtrahend.X,
		v.Y - subtrahend.Y,
		v.Z - subtrahend.Z,
	}
}

func (v Vector3) Magnitude() float64 {
	return math.Sqrt(v.X*v.X + v.Y*v.Y + v.Z*v.Z)
}

func (v Vector3) Normalized() Vector3 {
	mag := v.Magnitude()
	if mag == 0 {
		return Vector3{0, 0, 0} // Return a zero vector if v is zero
	}
	return Vector3{v.X / mag, v.Y / mag, v.Z / mag}
}

// Vector3i

type Vector3i struct {
	X, Y, Z int
}

func (v Vector3i) Mul(factor int) Vector3i {
	return Vector3i{
		v.X * factor,
		v.Y * factor,
		v.Z * factor,
	}
}

func (v Vector3i) Div(divisor float64) Vector3 {
	return Vector3{
		float64(v.X) / divisor,
		float64(v.Y) / divisor,
		float64(v.Z) / divisor,
	}
}

func (v Vector3i) Cross(factor Vector3i) Vector3i {
	return Vector3i{
		v.X*factor.Z - v.Z*factor.Y,
		v.Z*factor.X - v.X*factor.Z,
		v.X*factor.Y - v.Y*factor.X,
	}
}

func (v Vector3i) AddV3(addend Vector3) Vector3 {
	return Vector3{
		float64(v.X) + addend.X,
		float64(v.Y) + addend.Y,
		float64(v.Z) + addend.Z,
	}
}

func (v Vector3i) AddV3i(addend Vector3i) Vector3i {
	return Vector3i{
		v.X + addend.X,
		v.Y + addend.Y,
		v.Z + addend.Z,
	}
}

func (v Vector3i) Sub(subtrahend Vector3i) Vector3i {
	return Vector3i{
		v.X - subtrahend.X,
		v.Y - subtrahend.Y,
		v.Z - subtrahend.Z,
	}
}

func (v Vector3i) Magnitude() float64 {
	return math.Sqrt(float64(v.X*v.X + v.Y*v.Y + v.Z*v.Z))
}

func (v Vector3i) Normalized() Vector3 {
	mag := v.Magnitude()
	if mag == 0 {
		return Vector3{0, 0, 0} // Return a zero vector if v is zero
	}
	return Vector3{float64(v.X) / mag, float64(v.Y) / mag, float64(v.Z) / mag}
}

// Vector4

type Vector4 struct {
	X, Y, Z, W float64
}

func (v Vector4) Mul(factor float64) Vector4 {
	return Vector4{
		v.X * factor,
		v.Y * factor,
		v.Z * factor,
		v.W * factor,
	}
}

func (v Vector4) Div(divisor float64) Vector4 {
	return Vector4{
		v.X / divisor,
		v.Y / divisor,
		v.Z / divisor,
		v.W / divisor,
	}
}

func (v Vector4) Add(addend Vector4) Vector4 {
	return Vector4{
		v.X + addend.X,
		v.Y + addend.Y,
		v.Z + addend.Z,
		v.W + addend.W,
	}
}

func (v Vector4) Sub(subtrahend Vector4) Vector4 {
	return Vector4{
		v.X - subtrahend.X,
		v.Y - subtrahend.Y,
		v.Z - subtrahend.Z,
		v.W - subtrahend.W,
	}
}

func (v Vector4) ToVector3() Vector3 {
	return Vector3{
		v.X,
		v.Y,
		v.Z,
	}
}

// Triangle

type Triangle struct {
	A, B, C Vector3
	Normal  Vector3
}
