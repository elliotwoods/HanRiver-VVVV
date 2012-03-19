texture TexV <string uiname="Volume texture";>;
sampler SampVolume = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (TexV);
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
	AddressU = BORDER;
	AddressV = BORDER;
};

float4 VolumeLookup(Pixel pixel)
{
	pixel.xyz.x /= 2.0f;
	if (abs(pixel.xyz.x) > 1 || abs(pixel.xyz.y) > 1 || abs(pixel.xyz.z) > 1) 
		return 0;
	else {
		float2 texcd = float2((pixel.xyz.x + 1.0f) / 2.0f, (1.0f - pixel.xyz.y) / 2.0f);
		texcd.y /= (float) volumeResolution;
		int zlayer = floor((pixel.xyz.z + 1.0f) / 2.0f * volumeResolution);
		texcd.y += (float) zlayer / volumeResolution;
		return tex2D(SampVolume, texcd);

	}

}