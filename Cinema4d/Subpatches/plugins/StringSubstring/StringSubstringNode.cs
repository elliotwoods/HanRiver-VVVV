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
	[PluginInfo(Name = "Substring", Category = "String", Help = "Basic template with one string in/out", Tags = "")]
	#endregion PluginInfo
	public class StringSubstringNode : IPluginEvaluate
	{
		#region fields & pins
		[Input("Input", DefaultString = "hello c#")]
		IDiffSpread<string> FInput;

		[Input("Start")]
		IDiffSpread<int> FStart;
		
		[Input("Length")]
		IDiffSpread<int> FLength;
		
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

			if (FInput.IsChanged || FStart.IsChanged || FLength.IsChanged)
			{
				int start, length;
				for (int i = 0; i < SpreadMax; i++)
				{
					try
					{
						start = FStart[i];
						start %= FInput[i].Length;
						if (start < 0)
							start += FInput[i].Length;
						
						length = FLength[i];
						if (length < 0)
							length += FInput[i].Length;
						FOutput[i] = FInput[i].Substring(start, length);				
						FStatus[i] = "OK";
					} catch (Exception e) {
						FStatus[i] = e.Message;
					}
				}
			}

		}
	}
}
