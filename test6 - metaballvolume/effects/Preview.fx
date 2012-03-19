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

float3 center;

//texture
texture Tex <string uiname="Texture";>;
sampler Samp = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (Tex);          //apply a texture to the sampler
    MipFilter = NONE;         //sampler states
    MinFilter = NONE;
    MagFilter = NONE;
};

//texture
texture TexXYZT <string uiname="XYZT";>;
sampler SampXYZT = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (TexXYZT);          //apply a texture to the sampler
    MipFilter = NONE;         //sampler states
    MinFilter = NONE;
    MagFilter = NONE;
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

vs2ps VS(
    float4 Pos : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;

    //transform position
	float4 TexCdx = float4(TexCd.x, TexCd.y, 0, 0);
	float4 tex = tex2Dlod(SampXYZT, TexCdx);
	tex.xyz *= 2.0f;
	tex.xyz -= 1.0f;
	tex.w = 1.0f;
	tex.xyz -= center;
	Out.Pos = mul(tex, tWVP);
	//Out.Pos = mul(Pos, tWVP);
    //transform texturecoordinates
    Out.TexCd = TexCd;

    return Out;
}

// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------

float4 PS(vs2ps In): COLOR
{
    //In.TexCd = In.TexCd / In.TexCd.w; // for perpective texture projections (e.g. shadow maps) ps_2_0

    float4 col = tex2D(Samp, In.TexCd) + cAmb;
	//col.rg = In.TexCd;s
    col.a *= Alpha;
    return col;
}

// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

technique TLookup
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
    	FillMode = point;
        VertexShader = compile vs_3_0 VS();
        PixelShader = compile ps_3_0 PS();
    }
}