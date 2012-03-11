#region usings
using System;
using System.Windows;
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
	[PluginInfo(Name = "GetScreenDimensions", Category = "Windows", Help = "Basic template with one value in/out", Tags = "")]
	#endregion PluginInfo
	public class WindowsGetScreenDimensionsNode : IPluginEvaluate
	{
		#region fields & pins
		[Output("Width")]
		ISpread<int> FWidth;

		[Output("Height")]
		ISpread<int> FHeight;
		
		[Import()]
		ILogger FLogger;
		#endregion fields & pins

		//called when data for any output pin is requested
		public void Evaluate(int SpreadMax)
		{
			FWidth[0] = System.Windows.SystemParameters.WorkArea.Width;
			
		}
	}
}
