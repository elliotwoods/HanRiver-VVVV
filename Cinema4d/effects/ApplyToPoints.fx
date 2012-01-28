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

float Alpha = 1.0f;
//texture
texture TexXYZ <string uiname="XYZ";>;
sampler SampXYZ = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (TexXYZ);          //apply a texture to the sampler
    MipFilter = NONE;         //sampler states
    MinFilter = NONE;
    MagFilter = NONE;
};

//texture
texture TexRGBA <string uiname="RGBA";>;
sampler SampRGBA = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (TexRGBA);          //apply a texture to the sampler
    MipFilter = NONE;         //sampler states
    MinFilter = NONE;
    MagFilter = NONE;
};

struct vs2ps
{
    float4 Pos : POSITION;
    float4 TexCd : TEXCOORD0;
	float Size : PSIZE;
};

// --------------------------------------------------------------------------------------------------
// VERTEXSHADERS
// --------------------------------------------------------------------------------------------------
float size = 1.5;
vs2ps VS(
    float4 Pos : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;

	Out.TexCd = TexCd;
	float4 col = tex2Dlod(SampXYZ, TexCd);
	Pos.xyz = col.rgb;
	
	//transform position
    Out.Pos = mul(Pos, tWVP);

	Out.Size = size;
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
	return tex2D(SampRGBA, In.TexCd);
}

float4 PSWhite(vs2ps In): COLOR
{
    return Alpha;
}

// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

technique TApply
{
    pass P0
    {
        VertexShader = compile vs_3_0 VS();
        PixelShader = compile ps_3_0 PS();
     	FillMode = POINT;
    }
}

technique TWhite
{
    pass P0
    {
        VertexShader = compile vs_3_0 VS();
        PixelShader = compile ps_3_0 PSWhite();
     	FillMode = POINT;
    }
}