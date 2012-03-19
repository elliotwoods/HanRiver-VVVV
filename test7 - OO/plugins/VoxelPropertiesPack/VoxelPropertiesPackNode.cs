#region usings
using System;
using System.ComponentModel.Composition;

using VVVV.PluginInterfaces.V1;
using VVVV.PluginInterfaces.V2;
using VVVV.Utils.VColor;
using VVVV.Utils.VMath;

using VVVV.Core.Logging;
#endregion usings

namespace VVVV.Nodes
{
	struct SurfaceProperties
	{
		double Thickness;
	}
	struct ColorProperties
	{
		RGBAColor Color1;
		RGBAColor Color2;
		double Alpha;
		Vector2D GradientRotation;
		double GradientPosition;
	}
	struct WaveProperties
	{
		double Wavelength;
		double Frequency;
		double Amplitude;
	}
	struct VoxelProperties
	{
		public VoxelProperties(Matrix4x4 Transform, SurfaceProperties Surface, ColorProperties Color, WaveProperties Wave)
		{
			this.Transform = Transform;
			this.Surface = Surface;
			this.Color = Color;
			this.Wave = Wave;
		}
		
		public Matrix4x4 Transform;
		public SurfaceProperties Surface;
		public ColorProperties Color;
		public WaveProperties Wave;
	}
	
	#region PluginInfo
	[PluginInfo(Name = "Pack", Category = "VoxelProperties")]
	#endregion PluginInfo
	public class VoxelPropertiesPackNode : IPluginEvaluate
	{
		#region fields & pins
		[Input("Transform")]
		IDiffSpread<Matrix4x4> FPinInTransform;

		[Input("Surface")]
		IDiffSpread<SurfaceProperties> FPinInSurface;
		
		[Input("Color")]
		IDiffSpread<ColorProperties> FPinInColor;
		
		[Input("Wave")]
		IDiffSpread<WaveProperties> FPinInWave;
		
		[Output("Output")]
		ISpread<VoxelProperties> FOutput;

		[Import()]
		ILogger FLogger;
		#endregion fields & pins

		//called when data for any output pin is requested
		public void Evaluate(int SpreadMax)
		{
			if (FPinInTransform.IsChanged || FPinInSurface.IsChanged || FPinInColor.IsChanged || FPinInWave.IsChanged)
			{
				FOutput.SliceCount = SpreadMax;
				for (int i = 0; i < SpreadMax; i++)
				{
					VoxelProperties voxel = new VoxelProperties(
					FPinInTransform[i],
					FPinInSurface[i],
					FPinInColor[i],
					FPinInWave[i]
					);
					FOutput[i] = voxel;
				}
			}
		}
	}
	
		#region PluginInfo
	[PluginInfo(Name = "Unpack", Category = "VoxelProperties")]
	#endregion PluginInfo
	public class VoxelPropertiesUnackNode : IPluginEvaluate
	{
		#region fields & pins
		[Input("Input")]
		IDiffSpread<VoxelProperties> FInput;
		
		[Output("Transform")]
		ISpread<Matrix4x4> FPinOutTransform;

		[Output("Surface")]
		ISpread<SurfaceProperties> FPinOutSurface;
		
		[Output("Color")]
		ISpread<ColorProperties> FPinOutColor;
		
		[Output("Wave")]
		ISpread<WaveProperties> FPinOutWave;
		

		[Import()]
		ILogger FLogger;
		#endregion fields & pins

		//called when data for any output pin is requested
		public void Evaluate(int SpreadMax)
		{
			if (FInput.IsChanged)
			{
				FPinOutTransform.SliceCount = SpreadMax;
				FPinOutSurface.SliceCount = SpreadMax;
				FPinOutColor.SliceCount = SpreadMax;
				FPinOutWave.SliceCount = SpreadMax;
				for (int i = 0; i < SpreadMax; i++)
				{
					FPinOutTransform[i] = FInput[i].Transform;
					FPinOutSurface[i] = FInput[i].Surface;
					FPinOutColor[i] = FInput[i].Color;
					FPinOutWave[i] = FInput[i].Wave;
				}
			}
		}
	}
}
