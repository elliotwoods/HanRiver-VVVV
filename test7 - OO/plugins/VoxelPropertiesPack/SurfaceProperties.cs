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
	struct SurfaceProperties
	{
		public SurfaceProperties(double Thickness)
		{
			this.Thickness = Thickness;
		}
		public double Thickness;
	}
	
	[PluginInfo(Name = "Unpack", Category = "VoxelProperties", Version = "Surface")]
	public class VoxelPropertiesUnackSurfaceNode : IPluginEvaluate
	{
		#region fields & pins
		[Input("Input")]
		IDiffSpread<SurfaceProperties> FInput;
		
		[Output("Thickness")]
		ISpread<double> FThickness;

		[Import()]
		ILogger FLogger;
		#endregion fields & pins

		//called when data for any output pin is requested
		public void Evaluate(int SpreadMax)
		{
			if (FInput.IsChanged)
			{
				FThickness.SliceCount = SpreadMax;
				for (int i = 0; i < SpreadMax; i++)
				{
					FThickness[i] = FInput[i].Thickness;
				}
			}
		}
	}
	
	[PluginInfo(Name = "Pack", Category = "VoxelProperties", Version = "Surface")]
	public class VoxelPropertiesPackSurfaceNode : IPluginEvaluate
	{
		#region fields & pins
		[Input("Thickness")]
		IDiffSpread<double> FThickness;
		
		[Output("Output")]
		ISpread<SurfaceProperties> FOutput;

		[Import()]
		ILogger FLogger;
		#endregion fields & pins

		//called when data for any output pin is requested
		public void Evaluate(int SpreadMax)
		{
			if (FThickness.IsChanged)
			{
				FOutput.SliceCount = SpreadMax;
				for (int i = 0; i < SpreadMax; i++)
				{
					FOutput[i] = new SurfaceProperties(FThickness[i]);
				}
			}
		}
	}
}