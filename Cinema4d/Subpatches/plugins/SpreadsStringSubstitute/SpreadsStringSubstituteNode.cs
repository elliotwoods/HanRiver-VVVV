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
	[PluginInfo(Name = "Substitute", Category = "String", Version = "Spreads", Help = "Basic template with one string in/out", Tags = "")]
	#endregion PluginInfo
	public class SpreadsStringSubstituteNode : IPluginEvaluate
	{
		#region fields & pins
		[Input("Input", DefaultString = "hello c#")]
		ISpread<string> FInput;

		[Input("From")]
		ISpread<string> FFrom;
		
		[Input("To")]
		ISpread<string> FTo;
		
		[Output("Output")]
		ISpread<string> FOutput;

		[Output("Status")]
		ISpread<string> FStatus;

		[Import()]
		ILogger FLogger;
		#endregion fields & pins

		//called when data for any output pin is requested
		public void Evaluate(int SpreadMax)
		{
			FOutput.SliceCount = SpreadMax;
			FStatus.SliceCount = SpreadMax;
			
			for (int i = 0; i < SpreadMax; i++)
			{
				try
				{
					if (FFrom[i].Length > 0)
						FOutput[i] = FInput[i].Replace(FFrom[i], FTo[i]);
					else
						FOutput[i] = FInput[i];
					FStatus[i] = "OK";
				}
				catch (Exception e)
				{
					FStatus[i] = e.Message;
				}
				
				
			}
			//FLogger.Log(LogType.Debug, "Logging to Renderer (TTY)");
		}
	}
}
