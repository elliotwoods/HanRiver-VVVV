// --------------------------------------------------------------------------------------------------
// PARAMETERS:
// --------------------------------------------------------------------------------------------------

int width = 1280;
int height = 4000;
//texture
texture Tex <string uiname="Texture";>;
sampler Samp = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (Tex);          //apply a texture to the sampler
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
	Out.Pos.xy *= 2.0f;

    //transform texturecoordinates
    Out.TexCd = TexCd;

    return Out;
}

// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------
#define steps 5

float4 PS(vs2ps In): COLOR
{
	float2 dx = 1.0f / float2(width, height);
	//simple dilate
	//take maximum xyz of kernel
	float3 frontvalue = 0;
	float3 newvalue;
	float3 original;
	bool iscloser;
	for (int i = -(steps-1)/2; i<=(steps-1)/2; i++)
		for (int j = -(steps-1)/2; j<=(steps-1)/2; j++) {
			float2 texcd = In.TexCd + dx * float2(i, j);
			newvalue = tex2D(Samp, texcd).rgb;
			iscloser = length(newvalue) > length(frontvalue);
			frontvalue = iscloser ? newvalue : frontvalue;
			if (i == j == 0)
				original = newvalue;
		}
	float4 col;
	col.a = 1.0f;
	col.rgb = length(original) == 0 ? original : frontvalue;
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
    }
}