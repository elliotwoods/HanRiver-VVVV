// --------------------------------------------------------------------------------------------------
// VOXEL PARAMETERS
// --------------------------------------------------------------------------------------------------

texture TexXYZ <string uiname="XYZ";>;
sampler SampNoFilter = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (TexXYZ);          //apply a texture to the sampler
    MipFilter = NONE;         //sampler states
    MinFilter = NONE;
    MagFilter = NONE;
	AddressU = BORDER;
	AddressV = BORDER;
};

////
//scene settings
float3 center;
float4x4 rotation;
//
////


////
//graphic
float thickness = 0.3f;
float4 color1 : COLOR <String uiname="Color 1";>  = {1, 1, 1, 1};
float4 color2 : COLOR <String uiname="Color 2";>  = {1, 0, 0, 1};
float Alpha = 1;
float4x4 gradient;
//
////


////
//animation
float time;
float wavelength = 0.3; //scale of wave
float frequency = 1.0f; //speed of wave
float amplitude = 0.3f;
//
////


////
//volume
int volumeResolution = 32;
//
////

// --------------------------------------------------------------------------------------------------
// UTILITIES:
// --------------------------------------------------------------------------------------------------
struct Pixel {
	float3 xyz;
	float3 raw;
	float4 color;
	bool active;
};

Pixel ReadPixel(vs2ps In) {
	Pixel pixel;
	float4 position = 1;
	float4 xyzw;
	position.xyz = tex2D(SampNoFilter, In.TexCd).xyz;
	pixel.active = length(position.xyz) > 0;
	position.xyz -= center;
	position = mul(position, rotation);
	pixel.raw = position;
	xyzw = mul(position, tWorldInverse);
	pixel.xyz = xyzw.xyz;
	float gradientposition = clamp(mul(xyzw, gradient).z, 0, 1);
	pixel.color = lerp(color1, color2, gradientposition);
	return pixel;
}

float Wave(float position)
{
	return (position < 0) * (1.0f + position / thickness);
}