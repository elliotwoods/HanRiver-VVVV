//@author: Elliot Woods
//@help: Assembles the projected views into XYZ map
//@tags: HanRiver, volumetric
//@credits:

// --------------------------------------------------------------------------------------------------
// PARAMETERS:
// --------------------------------------------------------------------------------------------------

//transforms
float4x4 tW: WORLD;        //the models world matrix

//texture
texture TexXYZ <string uiname="XYZ";>;
texture TexDepth <string uiname="Depth";>;
texture TexRGBA <string uiname="RGBA";>;

sampler SampXYZ = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = TexXYZ;          //apply a texture to the sampler
    MipFilter = NONE;         //sampler states
    MinFilter = NONE;
    MagFilter = NONE;
};

sampler SampDepth = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = TexDepth;          //apply a texture to the sampler
    MipFilter = NONE;         //sampler states
    MinFilter = NONE;
    MagFilter = NONE;
};

sampler SampRGBA = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = TexRGBA;          //apply a texture to the sampler
    MipFilter = NONE;         //sampler states
    MinFilter = NONE;
    MagFilter = NONE;
};

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

vs2ps VS(
    float4 Pos : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;

    //transform position
    Out.Pos = Pos;
	Out.Pos.xy *= 2;
    //transform texturecoordinates
    Out.TexCd = TexCd;

    return Out;
}

// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------

float4x4 Reprojection;
float thickness = 0.5;
float4 PS(vs2ps In): COLOR
{
    //In.TexCd = In.TexCd / In.TexCd.w; // for perpective texture projections (e.g. shadow maps) ps_2_0

	float4 xyz = mul(tex2D(SampXYZ, In.TexCd), tW);
    
	float4 PosRP = mul(xyz, Reprojection);
	
	float2 TexCd = PosRP.xy;
	TexCd += 1.0f;
	TexCd /= 2.0f;
	TexCd.y = 1.0f - TexCd.y;
	
	float Depth = tex2D(SampDepth, TexCd).r;
	float4 RGBA = tex2D(SampRGBA, TexCd);
	float z = PosRP.z;
	float distance = z - Depth;
	float distanceSq = pow(distance, 2);
	float likeness = 1 - smoothstep(0, thickness * thickness, distanceSq);
	RGBA.a *= likeness;
	RGBA.a *= Depth > 0;
	//output
	float4 col;
	col = RGBA;
	
	//debug
	float4 debug;
	debug.a = 1;
	debug.rgb = likeness * Depth > 0;
	return col;
}

// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

technique TAssembleViews
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_2_0 VS();
        PixelShader = compile ps_2_0 PS();
    }
}