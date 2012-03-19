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
float4x4 tTransform;
//material properties
float Alpha = 1;

float3 center;

//texture
texture Tex <string uiname="Texture";>;
sampler Samp = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (Tex);          //apply a texture to the sampler
    MipFilter = POINT;         //sampler states
    MinFilter = POINT;
    MagFilter = POINT;
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
    Out.Pos = mul(Pos, tWVP);

    //transform texturecoordinates
    Out.TexCd = mul(TexCd, tTex);
	
    return Out;
}

// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------
#define count 10
float3 position[count];
float radius = 1.0f;
float thickness = 0.3;
float3 colour[count];
float3 lightdir;
float4 PS(vs2ps In): COLOR
{
    //In.TexCd = In.TexCd / In.TexCd.w; // for perpective texture projections (e.g. shadow maps) ps_2_0

	float3 xyz = tex2D(Samp, In.TexCd).xyz;
	xyz *= 2.0f;
	xyz -= 1.0f;
	xyz = mul(xyz, tTransform);
	xyz -= center;
	float density = 0;
	float3 col = 0;
	float3 r;
	float thisdensity;
	float3 direction = 0;
	for (int i=0; i<count; i++) {
		r = xyz - position[i];
		thisdensity = radius / length(r);
		density += thisdensity;
		col += colour[i] * thisdensity;
		direction += normalize(r) * (thisdensity > 0);
	}
	col /= (float) count;
	normalize(direction);
	col += clamp(dot(direction, -lightdir), 0, 1);
	
	//normalise denisty
	density /= count;
	float existence = (density > 1) * ((1.0f + thickness) - density) / thickness;
	float4 output;
	output.rgb = col;
	output.a = existence;
	return output;
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