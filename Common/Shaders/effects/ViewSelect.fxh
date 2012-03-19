// --------------------------------------------------------------------------------------------------
// DIRECTX PARAMETERS
// --------------------------------------------------------------------------------------------------

//transforms
float4x4 tW: WORLD;        //the models world matrix
float4x4 tV: VIEW;         //view matrix as set via Renderer (EX9)
float4x4 tP: PROJECTION;   //projection matrix as set via Renderer (EX9)
float4x4 tWVP: WORLDVIEWPROJECTION;
float4x4 tWorldInverse;
float4x4 tTex: TEXTUREMATRIX <string uiname="Texture Transform";>;

int ViewIndex : VIEWPORTINDEX;
int ViewCount : VIEWPORTCOUNT;
int ViewSelection = -1;

// --------------------------------------------------------------------------------------------------
// VERTEXSHADERS
// --------------------------------------------------------------------------------------------------

struct vs2ps
{
    float4 Pos : POSITION;
    float4 TexCd : TEXCOORD0;
};

vs2ps VSViewSelect(
    float4 Pos : POSITION,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;

    //transform position
    Out.Pos = mul(Pos, tW);

    //transform texturecoordinates
    Out.TexCd = mul(TexCd, tTex);

	Out.Pos *= ViewSelection == ViewIndex;
    return Out;
}