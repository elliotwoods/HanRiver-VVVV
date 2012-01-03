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
	[PluginInfo(Name = "LineBox", Category = "Value", Help = "Basic template with one value in/out", Tags = "")]
	#endregion PluginInfo
	public class ValueLineBoxNode : IPluginEvaluate
	{
		#region fields & pins
		[Input("WHD")]
		ISpread<Vector3D> FInput;

		[Output("Output")]
		ISpread<ISpread<Vector3D>> FOutput;

		[Import()]
		ILogger FLogger;
		#endregion fields & pins

		//called when data for any output pin is requested
		public void Evaluate(int SpreadMax)
		{
			
			ISpread<Vector3D> cage;
			ISpread<Vector3D> line;
			
			FOutput.SliceCount = 5 * FInput.SliceCount;
			
			for (int iBox=0; iBox<FInput.SliceCount; iBox++)
			{
				double W = FInput[iBox].x / 2;
				double H = FInput[iBox].y / 2;
				double D = FInput[iBox].z / 2;
				
				//first cage
				cage = FOutput[iBox*3 + 0];
				cage.SliceCount = 9;
				cage[0] = new Vector3D(-W, -H, -D);
				cage[1] = new Vector3D(-W, -H, D);
				cage[2] = new Vector3D(-W, H, D);
				cage[3] = new Vector3D(W, H, D);
				cage[4] = new Vector3D(W, -H, D);
				cage[5] = new Vector3D(W, -H, -D);
				cage[6] = new Vector3D(W, H, -D);
				cage[7] = new Vector3D(-W, H, -D);
				cage[8] = new Vector3D(-W, -H, -D);
				
				//4 fills
				line = FOutput[iBox*3 + 1];
				line.SliceCount = 2;
				line[0] = cage[1];
				line[1] = cage[4];
				
				line = FOutput[iBox*3 + 2];
				line.SliceCount = 2;
				line[0] = cage[2];
				line[1] = cage[7];
				
				line = FOutput[iBox*3 + 3];
				line.SliceCount = 2;
				line[0] = cage[3];
				line[1] = cage[6];
				
				line = FOutput[iBox*3 + 4];
				line.SliceCount = 2;
				line[0] = cage[5];
				line[1] = cage[8];
				
			}
			
			//FLogger.Log(LogType.Debug, "hi tty!");
		}
	}
}
