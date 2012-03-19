//@author: Elliot Woods
//@help: Volumetric tests for HanRiver project
//@tags: voxels, viewports, volume

#include "ViewSelect.fxh"
#include "VoxelUtilities.fxh"
#include "VolumeUtilities.fxh"

// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------

float4 PSFillProjector(vs2ps In) : COLOR
{
	return 1;
}

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

float4 PSFill(vs2ps In) : COLOR
{
	Pixel pixel = ReadPixel(In);
	float4 col;
	col.rgb = pixel.color;
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

technique TFillProjector
{
    pass P0
    {
        VertexShader = compile vs_2_0 VSViewSelect();
        PixelShader = compile ps_2_0 PSFillProjector();
    }
}

technique TShowActive
{
    pass P0
    {
        VertexShader = compile vs_2_0 VSViewSelect();
        PixelShader = compile ps_2_0 PSActive();
    }
}

technique TPassthrough
{
    pass P0
    {
        VertexShader = compile vs_2_0 VSViewSelect();
        PixelShader = compile ps_2_0 PSPassthrough();
    }
}

technique TAxis
{
    pass P0
    {
        VertexShader = compile vs_2_0 VSViewSelect();
        PixelShader = compile ps_2_0 PSAxis();
    }
}

technique TFill
{
    pass P0
    {
        VertexShader = compile vs_2_0 VSViewSelect();
        PixelShader = compile ps_2_0 PSFill();
    }
}

technique TSphere
{
    pass P0
    {
        VertexShader = compile vs_2_0 VSViewSelect();
        PixelShader = compile ps_2_0 PSSphere();
    }
}

technique TSphericalWave
{
    pass P0
    {
        VertexShader = compile vs_2_0 VSViewSelect();
        PixelShader = compile ps_2_0 PSSphericalWave();
    }
}

technique TSurfaceWave
{
	pass P0
    {
        VertexShader = compile vs_2_0 VSViewSelect();
        PixelShader = compile ps_2_0 PSSurfaceWave();
    }
}

technique TVolumeSample
{
	pass P0
    {
        VertexShader = compile vs_2_0 VSViewSelect();
        PixelShader = compile ps_2_0 PSVolumeSample();
    }
}