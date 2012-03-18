//@author: Elliot Woods
//@help: Select an output viewport for rendering
//@tags: viewports
//@credits:

// --------------------------------------------------------------------------------------------------
// PARAMETERS:
// --------------------------------------------------------------------------------------------------

//transforms
float4x4 tW: WORLD;        //the models world matrix
float4x4 tV: VIEW;         //view matrix as set via Renderer (EX9)
float4x4 tP: PROJECTION;   //projection matrix as set via Renderer (EX9)
float4x4 tWVP: WORLDVIEWPROJECTION;
float4x4 tWorldInverse;

int ViewIndex : VIEWPORTINDEX;
int ViewCount : VIEWPORTCOUNT;
int ViewSelection = -1;


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

//texture
texture Tex <string uiname="Texture";>;

sampler SampNoFilter = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (Tex);          //apply a texture to the sampler
    MipFilter = NONE;         //sampler states
    MinFilter = NONE;
    MagFilter = NONE;
	AddressU = BORDER;
	AddressV = BORDER;
};

texture TexV <string uiname="Volume texture";>;
sampler SampVolume = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (TexV);
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
	AddressU = BORDER;
	AddressV = BORDER;
};

float4x4 tTex: TEXTUREMATRIX <string uiname="Texture Transform";>;

//the data structure: vertexshader to pixelshader
//used as output data with the VS function
//and as input data with the PS function
struct vs2ps
{
    float4 Pos : POSITION;
    float4 TexCd : TEXCOORD0;
};

// --------------------------------------------------------------------------------------------------
// VERTEXSHADERS
// --------------------------------------------------------------------------------------------------
vs2ps VSx2(
    float4 Pos : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;

    //transform position
    Out.Pos = Pos;

    //transform texturecoordinates
    Out.TexCd = mul(TexCd, tTex);

	Out.Pos *= (ViewSelection == ViewIndex);
	Out.Pos.xy *= 2.0f;
    return Out;
}

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
	position.xyz = tex2D(SampNoFilter, In.TexCd).xyz;
	pixel.active = length(position.xyz) > 0;
	position.xyz -= center;
	position = mul(position, rotation);
	pixel.raw = position;
	pixel.xyz = mul(position, tWorldInverse);
	
	float gradientposition = clamp(mul(position, gradient).y, 0, 1);
	pixel.color = lerp(gradientposition, color1, color2);
	return pixel;
}

float Wave(float position)
{
	return (position < 0) * (1.0f + position / thickness);
}

float4 VolumeLookup(Pixel pixel)
{
	pixel.xyz.x /= 2.0f;
	if (abs(pixel.xyz.x) > 1 || abs(pixel.xyz.y) > 1 || abs(pixel.xyz.z) > 1) 
		return 0;
	else {
		float2 texcd = float2((pixel.xyz.x + 1.0f) / 2.0f, (1.0f - pixel.xyz.y) / 2.0f);
		texcd.y /= (float) volumeResolution;
		int zlayer = floor((pixel.xyz.z + 1.0f) / 2.0f * volumeResolution);
		texcd.y += (float) zlayer / volumeResolution;
		return tex2D(SampVolume, texcd);
	}
}

// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------


float4 PSActive(vs2ps In): COLOR
{
	Pixel pixel = ReadPixel(In);
	float4 col = pixel.active;
    col.a *= Alpha;
    return col;
}

float4 PSPassthrough(vs2ps In): COLOR
{
	Pixel pixel = ReadPixel(In);
	float4 col;
	col.rgb = pixel.raw;
    col.a = Alpha * pixel.active;
    return col;
}

float4 PSAxis(vs2ps In): COLOR
{
	Pixel pixel = ReadPixel(In);
	float4 col;
	col.rgb = abs(pixel.raw) < 0.05;
    col.a = Alpha * pixel.active;
    return col;
}

float4 PSSphere(vs2ps In): COLOR
{
	Pixel pixel = ReadPixel(In);
	float4 col;
	col.rgb = pixel.color * (length(pixel.xyz) < 0.5f) * length(pixel.xyz)* 2.0f;
    col.a = Alpha * pixel.active;
    return col;
}

float4 PSSphericalWave(vs2ps In): COLOR
{
	Pixel pixel = ReadPixel(In);
	float4 col;
	col.rgb = pixel.color * sin(length(pixel.xyz) / wavelength - time * frequency);
    col.a = Alpha * pixel.active;
    return col;
}

float4 PSSurfaceWave(vs2ps In) : COLOR
{
	Pixel pixel = ReadPixel(In);
	float4 col;
	col.rgb = pixel.color * Wave(pixel.xyz.y - amplitude * sin(length(pixel.xyz.xz) / wavelength - time * frequency ));
    col.a = Alpha * pixel.active;
    return col;	
}

float4 PSVolumeSample(vs2ps In) : COLOR
{
	Pixel pixel = ReadPixel(In);
	float4 col  = VolumeLookup(pixel) * pixel.color;
    col.a = Alpha * pixel.active;
    return col;	
}

// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

technique TShowActive
{
    pass P0
    {
        VertexShader = compile vs_2_0 VSx2();
        PixelShader = compile ps_2_0 PSActive();
    }
}

technique TPassthrough
{
    pass P0
    {
        VertexShader = compile vs_2_0 VSx2();
        PixelShader = compile ps_2_0 PSPassthrough();
    }
}

technique TAxis
{
    pass P0
    {
        VertexShader = compile vs_2_0 VSx2();
        PixelShader = compile ps_2_0 PSAxis();
    }
}

technique TSphere
{
    pass P0
    {
        VertexShader = compile vs_2_0 VSx2();
        PixelShader = compile ps_2_0 PSSphere();
    }
}

technique TSphericalWave
{
    pass P0
    {
        VertexShader = compile vs_2_0 VSx2();
        PixelShader = compile ps_2_0 PSSphericalWave();
    }
}

technique TSurfaceWave
{
	pass P0
    {
        VertexShader = compile vs_2_0 VSx2();
        PixelShader = compile ps_2_0 PSSurfaceWave();
    }
}

technique TVolumeSample
{
	pass P0
    {
        VertexShader = compile vs_2_0 VSx2();
        PixelShader = compile ps_2_0 PSVolumeSample();
    }
}