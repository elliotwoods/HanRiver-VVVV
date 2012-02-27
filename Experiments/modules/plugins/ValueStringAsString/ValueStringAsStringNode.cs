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
	[PluginInfo(Name = "AsString", Category = "String", Version = "Value", Help = "Basic template with one string in/out", Tags = "")]
	#endregion PluginInfo
	public class ValueStringAsStringNode : IPluginEvaluate
	{
		#region fields & pins
		[Input("Input")]
		ISpread<double> FInput;

		[Output("Output")]
		ISpread<string> FOutput;

		[Import()]
		ILogger FLogger;
		#endregion fields & pins

		//called when data for any output pin is requested
		public void Evaluate(int SpreadMax)
		{
			FOutput.SliceCount = SpreadMax;

			for (int i = 0; i < SpreadMax; i++)
				FOutput[i] = FInput[i].ToString();

			//FLogger.Log(LogType.Debug, "Logging to Renderer (TTY)");
		}
	}
}
