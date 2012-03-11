#region usings
using System;
using System.ComponentModel.Composition;
using System.Runtime.InteropServices;
using VVVV.PluginInterfaces.V1;
using VVVV.PluginInterfaces.V2;
using VVVV.Utils.VColor;
using VVVV.Utils.VMath;

using VVVV.Core.Logging;
#endregion usings

namespace VVVV.Nodes
{
	#region PluginInfo
	[PluginInfo(Name = "SetWindowShape", Category = "Windows", Help = "Basic template with one value in/out", Tags = "", AutoEvaluate=true)]
	#endregion PluginInfo
	public class WindowsSetWindowShapeNode : IPluginEvaluate
	{
		#region fields & pins
		[Input("X", DefaultValue = 0)]
		ISpread<int> FX;
		
		[Input("Y", DefaultValue = 0)]
		ISpread<int> FY;

		[Input("Width", DefaultValue = 512)]
		ISpread<int> FWidth;
		
		[Input("Height", DefaultValue = 512)]
		ISpread<int> FHeight;
		
		[Input("Handle", DefaultValue = 0)]
		ISpread<int> FHandle;
		
		[Input("Apply", IsBang=true)]
		ISpread<bool> FApply;
		
		[Output("Success")]
		ISpread<bool> FSuccess;
		
		[Import()]
		ILogger FLogger;
		#endregion fields & pins

		[DllImport("User32.dll", ExactSpelling=true, CharSet = System.Runtime.InteropServices.CharSet.Auto)]
		private static extern bool MoveWindow(IntPtr hWnd, int x, int y, int width, int height, bool repaint);
		
		//called when data for any output pin is requested
		public void Evaluate(int SpreadMax)
		{
			FSuccess.SliceCount = SpreadMax;
			for (int i=0; i<SpreadMax; i++)
			{
				if (FApply[i])
				{
					FSuccess[i] = MoveWindow((IntPtr) FHandle[i], FX[i], FY[i], FWidth[i], FHeight[i], true);
				}
			}
		}
	}
}
