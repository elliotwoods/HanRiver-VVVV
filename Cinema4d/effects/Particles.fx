//@author: vvvv group
//@help: draws a mesh with a constant color
//@tags: template, basic
//@credits:

// --------------------------------------------------------------------------------------------------
// PARAMETERS:
// --------------------------------------------------------------------------------------------------

//transforms
float4x4 tW: WORLD;        //the models world matrix
float4x4 tV: VIEW;         //view matrix as set via Renderer (EX9)
float4x4 tP: PROJECTION;   //projection matrix as set via Renderer (EX9)
float4x4 tWVP: WORLDVIEWPROJECTION;

//material properties
float4 cAmb : COLOR <String uiname="Color";>  = {1, 1, 1, 1};
float Alpha = 1;

//texture
texture TexXYZ <string uiname="TextureXYZ";>;
sampler SampXYZ = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (TexXYZ);          //apply a texture to the sampler
    MipFilter = LINEAR;         //sampler states
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

//texture
texture TexDepth <string uiname="Depth";>;
sampler SampDepth = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (TexDepth);          //apply a texture to the sampler
    MipFilter = LINEAR;         //sampler states
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

//texture
texture TexRGBA <string uiname="RGBA";>;
sampler SampRGBA = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (TexRGBA);          //apply a texture to the sampler
    MipFilter = LINEAR;         //sampler states
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

//the data structure: vertexshader to pixelshader
//used as output data with the VS function
//and as input data with the PS function
struct vs2ps
{
    float4 Pos : POSITION;
    float4 TexCd : TEXCOORD0;
	float Size : PSIZE;
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

	float4 tex = (float4)0;
	tex.xy = TexCd.xy;
	
	float4 col = tex2Dlod(SampXYZ, tex);
	Pos.xyz = col.rgb;
	
	Out.TexCd.xyz = Pos.xyz;
	Out.TexCd.w = 1.0f;
	
	//transform position
    Out.Pos = mul(Pos, tWVP);

	Out.Size = 2;
    return Out;
}

// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------
float thickness = 0.1;
float4x4 tTransform;
float depthMult = 10.0f;
float4 PS(vs2ps In): COLOR
{
    //In.TexCd = In.TexCd / In.TexCd.w; // for perpective texture projections (e.g. shadow maps) ps_2_0

	float4 world = In.TexCd;
	world.y = 1 - world.y;
	world = mul(world, tTransform);
	
	float4 depthLook = tex2D(SampDepth, world.xy) * depthMult;
	float4 col;
	//col.rgb = In.TexCd.xyz;
	col.rgb = tex2D(SampRGBA, world.xy);
    col.a = 1 - smoothstep(0,thickness,abs(world.z  - depthLook));
    return col;
}

// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

technique TConstant
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_3_0 VS();
        PixelShader = compile ps_3_0 PS();
    	FillMode = POINT;
    }
}