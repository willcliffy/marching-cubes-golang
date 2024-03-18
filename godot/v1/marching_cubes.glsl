#[compute]
#version 460


const int cornerIndexAFromEdge[12] = {0,1,2,3,4,5,6,7,0,1,2,3};
const int cornerIndexBFromEdge[12] = {1,2,3,0,5,6,7,4,4,5,6,7};

const int offsets[256] = {0,0,3,6,12,15,21,27,36,39,45,51,60,66,75,84,90,93,99,105,114,120,129,138,150,156,165,174,186,195,207,219,228,231,237,243,252,258,267,276,288,294,303,312,324,333,345,357,366,372,381,390,396,405,417,429,438,447,459,471,480,492,507,522,528,531,537,543,552,558,567,576,588,594,603,612,624,633,645,657,666,672,681,690,702,711,723,735,750,759,771,783,798,810,825,840,852,858,867,876,888,897,909,915,924,933,945,957,972,984,999,1008,1014,1023,1035,1047,1056,1068,1083,1092,1098,1110,1125,1140,1152,1167,1173,1185,1188,1191,1197,1203,1212,1218,1227,1236,1248,1254,1263,1272,1284,1293,1305,1317,1326,1332,1341,1350,1362,1371,1383,1395,1410,1419,1425,1437,1446,1458,1467,1482,1488,1494,1503,1512,1524,1533,1545,1557,1572,1581,1593,1605,1620,1632,1647,1662,1674,1683,1695,1707,1716,1728,1743,1758,1770,1782,1791,1806,1812,1827,1839,1845,1848,1854,1863,1872,1884,1893,1905,1917,1932,1941,1953,1965,1980,1986,1995,2004,2010,2019,2031,2043,2058,2070,2085,2100,2106,2118,2127,2142,2154,2163,2169,2181,2184,2193,2205,2217,2232,2244,2259,2268,2280,2292,2307,2322,2328,2337,2349,2355,2358,2364,2373,2382,2388,2397,2409,2415,2418,2427,2433,2445,2448,2454,2457,2460};
const int lengths[256] = {0,3,3,6,3,6,6,9,3,6,6,9,6,9,9,6,3,6,6,9,6,9,9,12,6,9,9,12,9,12,12,9,3,6,6,9,6,9,9,12,6,9,9,12,9,12,12,9,6,9,9,6,9,12,12,9,9,12,12,9,12,15,15,6,3,6,6,9,6,9,9,12,6,9,9,12,9,12,12,9,6,9,9,12,9,12,12,15,9,12,12,15,12,15,15,12,6,9,9,12,9,12,6,9,9,12,12,15,12,15,9,6,9,12,12,9,12,15,9,6,12,15,15,12,15,6,12,3,3,6,6,9,6,9,9,12,6,9,9,12,9,12,12,9,6,9,9,12,9,12,12,15,9,6,12,9,12,9,15,6,6,9,9,12,9,12,12,15,9,12,12,15,12,15,15,12,9,12,12,9,12,15,15,12,12,9,15,6,15,12,6,3,6,9,9,12,9,12,12,15,9,12,12,15,6,9,9,6,9,12,12,15,12,15,15,6,12,9,15,12,9,6,12,3,9,12,12,15,12,15,9,12,12,15,15,6,9,12,6,3,6,9,9,6,9,12,6,3,9,6,12,3,6,3,3,0};


struct Triangle {
    vec4 a;
    vec4 b;
    vec4 c;
    vec4 norm;
};


// #------ SIMPLEX NOISE ------#
// Description : Array and textureless GLSL 2D/3D/4D simplex 
//               noise functions.
//      Author : Ian McEwan, Ashima Arts.
//  Maintainer : stegu
//     Lastmod : 20201014 (stegu)
//     License : Copyright (C) 2011 Ashima Arts. All rights reserved.
//               Distributed under the MIT License. See LICENSE file.
//               https://github.com/ashima/webgl-noise
//               https://github.com/stegu/webgl-noise
vec3 mod289(vec3 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 mod289(vec4 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 permute(vec4 x) {
    return mod289(((x*34.0)+1.0)*x);
}

vec4 taylorInvSqrt(vec4 r)
{
    return 1.79284291400159 - 0.85373472095314 * r;
}

float snoise(vec3 v)
{ 
    const vec2  C = vec2(1.0/6.0, 1.0/3.0) ;
    const vec4  D = vec4(0.0, 0.5, 1.0, 2.0);

    // First corner
    vec3 i  = floor(v + dot(v, C.yyy) );
    vec3 x0 =   v - i + dot(i, C.xxx) ;

    // Other corners
    vec3 g = step(x0.yzx, x0.xyz);
    vec3 l = 1.0 - g;
    vec3 i1 = min( g.xyz, l.zxy );
    vec3 i2 = max( g.xyz, l.zxy );

    //   x0 = x0 - 0.0 + 0.0 * C.xxx;
    //   x1 = x0 - i1  + 1.0 * C.xxx;
    //   x2 = x0 - i2  + 2.0 * C.xxx;
    //   x3 = x0 - 1.0 + 3.0 * C.xxx;
    vec3 x1 = x0 - i1 + C.xxx;
    vec3 x2 = x0 - i2 + C.yyy;
    vec3 x3 = x0 - D.yyy;

    // Permutations
    i = mod289(i); 
    vec4 p = permute( permute( permute( 
            i.z + vec4(0.0, i1.z, i2.z, 1.0 ))
            + i.y + vec4(0.0, i1.y, i2.y, 1.0 )) 
            + i.x + vec4(0.0, i1.x, i2.x, 1.0 ));

    // Gradients: 7x7 points over a square, mapped onto an octahedron.
    // The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
    float n_ = 0.142857142857; // 1.0/7.0
    vec3  ns = n_ * D.wyz - D.xzx;

    vec4 j = p - 49.0 * floor(p * ns.z * ns.z);  //  mod(p,7*7)

    vec4 x_ = floor(j * ns.z);
    vec4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)

    vec4 x = x_ *ns.x + ns.yyyy;
    vec4 y = y_ *ns.x + ns.yyyy;
    vec4 h = 1.0 - abs(x) - abs(y);

    vec4 b0 = vec4( x.xy, y.xy );
    vec4 b1 = vec4( x.zw, y.zw );

    vec4 s0 = floor(b0)*2.0 + 1.0;
    vec4 s1 = floor(b1)*2.0 + 1.0;
    vec4 sh = -step(h, vec4(0.0));

    vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
    vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;

    vec3 p0 = vec3(a0.xy,h.x);
    vec3 p1 = vec3(a0.zw,h.y);
    vec3 p2 = vec3(a1.xy,h.z);
    vec3 p3 = vec3(a1.zw,h.w);

    //Normalise gradients
    vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
    p0 *= norm.x;
    p1 *= norm.y;
    p2 *= norm.z;
    p3 *= norm.w;

    // Mix final noise value
    vec4 m = max(0.5 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
    m = m * m;
    return 105.0 * dot(
        m * m,
        vec4(
            dot(p0, x0),
            dot(p1, x1),
            dot(p2, x2),
            dot(p3, x3)
        )
    );
}

float snoise_alt(vec3 v)
{
    const vec2 C = vec2(1.0 / 6.0, 1.0 / 3.0);

    // First corner
    vec3 i  = floor(v + dot(v, C.yyy));
    vec3 x0 = v   - i + dot(i, C.xxx);

    // Other corners
    vec3 g = step(x0.yzx, x0.xyz);
    vec3 l = 1.0 - g;
    vec3 i1 = min(g.xyz, l.zxy);
    vec3 i2 = max(g.xyz, l.zxy);

    // x1 = x0 - i1  + 1.0 * C.xxx;
    // x2 = x0 - i2  + 2.0 * C.xxx;
    // x3 = x0 - 1.0 + 3.0 * C.xxx;
    vec3 x1 = x0 - i1 + C.xxx;
    vec3 x2 = x0 - i2 + C.yyy;
    vec3 x3 = x0 - 0.5;

    // Permutations
    i = mod289(i); // Avoid truncation effects in permutation
    vec4 p =
      permute(permute(permute(i.z + vec4(0.0, i1.z, i2.z, 1.0))
                            + i.y + vec4(0.0, i1.y, i2.y, 1.0))
                            + i.x + vec4(0.0, i1.x, i2.x, 1.0));

    // Gradients: 7x7 points over a square, mapped onto an octahedron.
    // The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
    vec4 j = p - 49.0 * floor(p / 49.0);  // mod(p,7*7)

    vec4 x_ = floor(j / 7.0);
    vec4 y_ = floor(j - 7.0 * x_);  // mod(j,N)

    vec4 x = (x_ * 2.0 + 0.5) / 7.0 - 1.0;
    vec4 y = (y_ * 2.0 + 0.5) / 7.0 - 1.0;

    vec4 h = 1.0 - abs(x) - abs(y);

    vec4 b0 = vec4(x.xy, y.xy);
    vec4 b1 = vec4(x.zw, y.zw);

    vec4 s0 = floor(b0) * 2.0 + 1.0;
    vec4 s1 = floor(b1) * 2.0 + 1.0;
    vec4 sh = -step(h, vec4(0.0));

    vec4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
    vec4 a1 = b1.xzyw + s1.xzyw * sh.zzww;

    vec3 g0 = vec3(a0.xy, h.x);
    vec3 g1 = vec3(a0.zw, h.y);
    vec3 g2 = vec3(a1.xy, h.z);
    vec3 g3 = vec3(a1.zw, h.w);

    // Normalise gradients
    vec4 norm = taylorInvSqrt(vec4(dot(g0, g0), dot(g1, g1), dot(g2, g2), dot(g3, g3)));
    g0 *= norm.x;
    g1 *= norm.y;
    g2 *= norm.z;
    g3 *= norm.w;

    // Mix final noise value
    vec4 m = max(0.6 - vec4(dot(x0, x0), dot(x1, x1), dot(x2, x2), dot(x3, x3)), 0.0);
    m = m * m;
    m = m * m;

    vec4 px = vec4(dot(x0, g0), dot(x1, g1), dot(x2, g2), dot(x3, g3));
    return 42.0 * dot(m, px);
}

vec4 snoise_grad(vec3 v)
{
    const vec2 C = vec2(1.0 / 6.0, 1.0 / 3.0);

    // First corner
    vec3 i  = floor(v + dot(v, C.yyy));
    vec3 x0 = v   - i + dot(i, C.xxx);

    // Other corners
    vec3 g = step(x0.yzx, x0.xyz);
    vec3 l = 1.0 - g;
    vec3 i1 = min(g.xyz, l.zxy);
    vec3 i2 = max(g.xyz, l.zxy);

    // x1 = x0 - i1  + 1.0 * C.xxx;
    // x2 = x0 - i2  + 2.0 * C.xxx;
    // x3 = x0 - 1.0 + 3.0 * C.xxx;
    vec3 x1 = x0 - i1 + C.xxx;
    vec3 x2 = x0 - i2 + C.yyy;
    vec3 x3 = x0 - 0.5;

    // Permutations
    i = mod289(i); // Avoid truncation effects in permutation
    vec4 p =
      permute(permute(permute(i.z + vec4(0.0, i1.z, i2.z, 1.0))
                            + i.y + vec4(0.0, i1.y, i2.y, 1.0))
                            + i.x + vec4(0.0, i1.x, i2.x, 1.0));

    // Gradients: 7x7 points over a square, mapped onto an octahedron.
    // The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
    vec4 j = p - 49.0 * floor(p / 49.0);  // mod(p,7*7)

    vec4 x_ = floor(j / 7.0);
    vec4 y_ = floor(j - 7.0 * x_);  // mod(j,N)

    vec4 x = (x_ * 2.0 + 0.5) / 7.0 - 1.0;
    vec4 y = (y_ * 2.0 + 0.5) / 7.0 - 1.0;

    vec4 h = 1.0 - abs(x) - abs(y);

    vec4 b0 = vec4(x.xy, y.xy);
    vec4 b1 = vec4(x.zw, y.zw);

    //vec4 s0 = vec4(lessThan(b0, 0.0)) * 2.0 - 1.0;
    //vec4 s1 = vec4(lessThan(b1, 0.0)) * 2.0 - 1.0;
    vec4 s0 = floor(b0) * 2.0 + 1.0;
    vec4 s1 = floor(b1) * 2.0 + 1.0;
    vec4 sh = -step(h, vec4(0.0));

    vec4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
    vec4 a1 = b1.xzyw + s1.xzyw * sh.zzww;

    vec3 g0 = vec3(a0.xy, h.x);
    vec3 g1 = vec3(a0.zw, h.y);
    vec3 g2 = vec3(a1.xy, h.z);
    vec3 g3 = vec3(a1.zw, h.w);

    // Normalise gradients
    vec4 norm = taylorInvSqrt(vec4(dot(g0, g0), dot(g1, g1), dot(g2, g2), dot(g3, g3)));
    g0 *= norm.x;
    g1 *= norm.y;
    g2 *= norm.z;
    g3 *= norm.w;

    // Compute noise and gradient at P
    vec4 m = max(0.6 - vec4(dot(x0, x0), dot(x1, x1), dot(x2, x2), dot(x3, x3)), 0.0);
    vec4 m2 = m * m;
    vec4 m3 = m2 * m;
    vec4 m4 = m2 * m2;
    vec3 grad =
        -6.0 * m3.x * x0 * dot(x0, g0) + m4.x * g0 +
        -6.0 * m3.y * x1 * dot(x1, g1) + m4.y * g1 +
        -6.0 * m3.z * x2 * dot(x2, g2) + m4.z * g2 +
        -6.0 * m3.w * x3 * dot(x3, g3) + m4.w * g3;
    vec4 px = vec4(dot(x0, g0), dot(x1, g1), dot(x2, g2), dot(x3, g3));
    return 42.0 * vec4(grad, dot(m4, px));
}

///
/// Buffers
///

layout(set = 0, binding = 0, std430) restrict buffer LookupTable
{
    int data[];
}
lookup_table;

layout(set = 0, binding = 1, std430) restrict buffer InputParams
{
    float noiseScale;
    float isoLevel;
    float numVoxelsPerAxis;
    float scale;
    // float posX;
    // float posY;
    // float posZ;
    float noiseOffsetX;
    float noiseOffsetY;
    float noiseOffsetZ;
}
input_params;

layout(set = 0, binding = 2, std430) restrict buffer OutputData
{
    Triangle data[];
}
output_data;

layout(set = 0, binding = 3, std430) coherent buffer OutputLength
{
    uint output_length;
};

///
/// User-defined function
///

vec4 sample_position(vec3 coord)
{
    vec3 worldPos = input_params.scale * (coord / vec3(input_params.numVoxelsPerAxis) - vec3(0.5));
    vec3 noiseOffset = vec3(input_params.noiseOffsetX, input_params.noiseOffsetY, input_params.noiseOffsetZ);
    vec3 samplePos = (worldPos + noiseOffset) * input_params.noiseScale / input_params.scale;

    float sum = 0;
    float amplitude = 1;
    float weight = 1;

    for (int i = 0; i < 6; i ++)
    {
        float noise = snoise(samplePos) * 2 - 1;
        noise = 1 - abs(noise);
        noise *= noise;
        noise *= weight;
        weight = max(0, min(1, noise * 10));
        sum += noise * amplitude;
        samplePos *= 8;
        amplitude *= 0.25;

        // float n = snoise((pos+offsetNoise) * frequency + offsets[j] + offset);
        // float v = 1-abs(n);
        // v = v*v;
        // v *= weight;
        // weight = max(min(v*weightMultiplier,1),0);
        // noise += v * amplitude;
        // amplitude *= persistence;
        // frequency *= lacunarity;
    }

    float density = sum - (worldPos.y+100) / 300;

    return vec4(worldPos, density);
}

vec4 sample_density(vec3 coord)
{
    // TODO - is this important?
    vec3 pos = coord * spacing - boundsSize/2;
    //vec3 pos = input_params.scale * (coord / vec3(input_params.numVoxelsPerAxis) - vec3(0.5));

    vec3 noiseOffset = vec3(input_params.noiseOffsetX, input_params.noiseOffsetY, input_params.noiseOffsetZ);

    // TODO - move to input params
    const float weightMultiplier = 3.61;
    const float persistence = 0.52;
    const float lacunarity = 2;
    const float floorOffset = 5.19;
    const float noiseWeight = 1.0;
    const float hardFloor = -3;
    const float hardFloorWeight = 100;

    float noise = 0;

    float frequency = input_params.noiseScale / 100;
    float amplitude = 1;
    float weight = 1;

    for (int j =0; j < 6; j ++) {
        float n = snoise_alt(pos * frequency + noiseOffset);
        float v = 1-abs(n);
        v = v*v;
        v *= weight;
        weight = max(min(v*weightMultiplier, 1), 0);
        noise += v * amplitude;
        amplitude *= persistence;
        frequency *= lacunarity;
    }

    // NOTE: removed terracing
    float density = -(pos.y + floorOffset) + noise * noiseWeight + (pos.y);

    if (pos.y < hardFloor) {
        density += hardFloorWeight;
    }

    return vec4(pos, -density);
}


vec4 interpolateVerts(vec4 v1, vec4 v2)
{
    float t = (input_params.isoLevel - v1.w) / (v2.w - v1.w);
    return v1 + t * (v2 - v1);
}

///
/// Main
///

layout(local_size_x = 8, local_size_y = 8, local_size_z = 8) in;
void main()
{
    vec3 id = gl_GlobalInvocationID;

    vec4 corners[8] = {
        sample_density(vec3(id.x + 0, id.y + 0, id.z + 0)),
        sample_density(vec3(id.x + 1, id.y + 0, id.z + 0)),
        sample_density(vec3(id.x + 1, id.y + 0, id.z + 1)),
        sample_density(vec3(id.x + 0, id.y + 0, id.z + 1)),
        sample_density(vec3(id.x + 0, id.y + 1, id.z + 0)),
        sample_density(vec3(id.x + 1, id.y + 1, id.z + 0)),
        sample_density(vec3(id.x + 1, id.y + 1, id.z + 1)),
        sample_density(vec3(id.x + 0, id.y + 1, id.z + 1))
    };

    uint cubeIndex = 0;
    float isoLevel = input_params.isoLevel;
    if (corners[0].w < isoLevel) cubeIndex |= 1;
    if (corners[1].w < isoLevel) cubeIndex |= 2;
    if (corners[2].w < isoLevel) cubeIndex |= 4;
    if (corners[3].w < isoLevel) cubeIndex |= 8;
    if (corners[4].w < isoLevel) cubeIndex |= 16;
    if (corners[5].w < isoLevel) cubeIndex |= 32;
    if (corners[6].w < isoLevel) cubeIndex |= 64;
    if (corners[7].w < isoLevel) cubeIndex |= 128;

    int numIndices = lengths[cubeIndex];
    int offset = offsets[cubeIndex];

    for (int i = 0; i < numIndices; i += 3) {
        int v0 = lookup_table.data[offset + i];
        int v1 = lookup_table.data[offset + 1 + i];
        int v2 = lookup_table.data[offset + 2 + i];

        int a0 = cornerIndexAFromEdge[v0];
        int b0 = cornerIndexBFromEdge[v0];

        int a1 = cornerIndexAFromEdge[v1];
        int b1 = cornerIndexBFromEdge[v1];

        int a2 = cornerIndexAFromEdge[v2];
        int b2 = cornerIndexBFromEdge[v2];

        // Calculate vertex positions
        Triangle currTri;
        currTri.a = interpolateVerts(corners[a0], corners[b0]);
        currTri.b = interpolateVerts(corners[a1], corners[b1]);
        currTri.c = interpolateVerts(corners[a2], corners[b2]);

        vec3 ab = currTri.b.xyz - currTri.a.xyz;
        vec3 ac = currTri.c.xyz - currTri.a.xyz;
        currTri.norm = -vec4(normalize(cross(ab,ac)), 0);

        uint index = atomicAdd(output_length, 1u);
        output_data.data[index] = currTri;
    }
}
