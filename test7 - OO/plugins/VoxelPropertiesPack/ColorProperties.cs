#region usings
using System;
using System.ComponentModel.Composition;

using VVVV.PluginInterfaces.V1;
using VVVV.PluginInterfaces.V2;
using VVVV.Utils.VColor;
using VVVV.Utils.VMath;

using VVVV.Core.Logging;
#endregion usings

namespace VVVV.Nodes.VoxelProperties
{
	struct ColorProperties
	{
		public ColorProperties(RGBAColor Color1, RGBAColor Color2, double Alpha, Vector2D GradientRotation, double GradientPosition)
		{
			this.Color1 = Color1;
			this.Color2 = Color2;
			this.Alpha = Alpha;
			this.GradientRotation = GradientRotation;
			this.GradientPosition = GradientPosition;
		}
		public RGBAColor Color1;
		public RGBAColor Color2;
		public double Alpha;
		public Vector2D GradientRotation;
		public double GradientPosition;
	}
	
	[PluginInfo(Name = "Pack", Category = "VoxelProperties", Version = "Color")]
	public class VoxelPropertiesPackColorNode : IPluginEvaluate
	{
		#region fields & pins
		[Input("Color1")]
		IDiffSpread<RGBAColor> FColor1;
		
		[Input("Color2")]
		IDiffSpread<RGBAColor> FColor2;	
		
		[Input("Alpha")]
		IDiffSpread<double> FAlpha;
		
		[Input("Gradient Rotation")]
		IDiffSpread<Vector2D> FGradientRotation;
		
		[Input("Gradient Position")]
		IDiffSpread<double> FGradientPosition;
		
		[Output("Output")]
		ISpread<ColorProperties> FOutput;

		[Import()]
		ILogger FLogger;
		#endregion fields & pins

		//called when data for any output pin is requested
		public void Evaluate(int SpreadMax)
		{
			if (FColor1.IsChanged || FColor2.IsChanged || FAlpha.IsChanged || FGradientPosition.IsChanged || FGradientRotation.IsChanged)
			{
				FOutput.SliceCount = SpreadMax;
				for (int i = 0; i < SpreadMax; i++)
				{
					FOutput[i] = new ColorProperties(FColor1[i], FColor2[i], FAlpha[i], FGradientRotation[i], FGradientPosition[i]);
				}
			}
		}
	}
	
	[PluginInfo(Name = "Unpack", Category = "VoxelProperties", Version = "Color")]
	public class VoxelPropertiesUnackColorNode : IPluginEvaluate
	{
		#region fields & pins
		[Input("Input")]
		IDiffSpread<ColorProperties> FInput;
		
		[Output("Color1")]
		ISpread<RGBAColor> FColor1;
		
		[Output("Color2")]
		ISpread<RGBAColor> FColor2;

		[Output("Alpha")]
		ISpread<double> FAlpha;
		
		[Output("Gradient Rotation")]
		ISpread<Vector2D> FGradientRotation;
		
		[Output("Gradient Position")]
		ISpread<double> FGradientPosition;

		[Import()]
		ILogger FLogger;
		#endregion fields & pins

		//called when data for any output pin is requested
		public void Evaluate(int SpreadMax)
		{
			if (FInput.IsChanged)
			{
				FColor1.SliceCount = SpreadMax;
				FColor2.SliceCount = SpreadMax;
				for (int i = 0; i < SpreadMax; i++)
				{
					FColor1[i] = FInput[i].Color1;
					FColor2[i] = FInput[i].Color2;
					FAlpha[i] = FInput[i].Alpha;
					FGradientRotation[i] = FInput[i].GradientRotation;
					FGradientPosition[i] = FInput[i].GradientPosition;
				}
			}
			FLogger.Log(FLogger.Log(LogType.Debug, "hi tty!");
		}
	}
}