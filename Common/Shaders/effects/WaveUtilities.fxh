////
//wave
float time;
float wavelength = 0.3; //scale of wave
float frequency = 1.0f; //speed of wave
float amplitude = 0.3f;
//
////

float Wave(float position)
{
	return (position < 0) * (1.0f + position / thickness);
}