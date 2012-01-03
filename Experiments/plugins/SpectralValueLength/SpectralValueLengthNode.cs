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
	#region PluginInfo
	[PluginInfo(Name = "Length", Category = "Value", Version = "Spectral", Help = "Basic template with one value in/out", Tags = "")]
	#endregion PluginInfo
	public class SpectralValueLengthNode : IPluginEvaluate
	{
		#region fields & pins
		[Input("Input", DefaultValue = 1.0)]
		ISpread<ISpread<double>> FInput;

		[Output("Output")]
		ISpread<double> FOutput;

		[Import()]
		ILogger FLogger;
		#endregion fields & pins

		//called when data for any output pin is requested
		public void Evaluate(int SpreadMax)
		{
			FOutput.SliceCount = FInput.SliceCount;

			double total;
			for (int i = 0; i < SpreadMax; i++)
			{
				total = 0;
				foreach(double d in FInput[i])
					total += d*d;
				FOutput[i] = Math.Sqrt(total);
			}

			//FLogger.Log(LogType.Debug, "hi tty!");
		}
	}
}
