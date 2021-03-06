// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
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