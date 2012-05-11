//@author: Elliot Woods
//@help: Volumetric tests for HanRiver project
//@tags: voxels, viewports, volume

#include "ViewSelect.fxh"
#include "VoxelUtilities.fxh"
#include "DebugTechniques.fxh"

// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------
#define count 5
float3 position[count];
float radius = 1.0f;
float3 colour[count];
float4 PSMetaballs(vs2ps In): COLOR
{
	Pixel pixel = ReadPixel(In);
	float density = 0;
	float3 col = 0;
	float3 r;
	float thisdensity;
	float3 direction = 0;
	for (int i=0; i<count; i++) {
		r = pixel.xyz - position[i];
		thisdensity = radius / length(r);
		density += thisdensity;
		col += pixel.color.rgb * thisdensity;
		direction += normalize(r) * (thisdensity > 0);
	}
	col /= (float) count;
	normalize(direction);
	
	//normalise denisty
	density /= count;
	float existence = (density > 1) * ((1.0f + thickness) - density) / thickness;
	float4 output;
	output.rgb = pow(col, gamma);
	output.a = existence * pixel.active * Alpha;
	return output;
}


// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

technique TMetaballs
{
    pass P0
    {
        VertexShader = compile vs_3_0 VSViewSelect();
        PixelShader = compile ps_3_0 PSMetaballs();
    }
}