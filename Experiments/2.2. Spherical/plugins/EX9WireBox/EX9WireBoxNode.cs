#region usings
using System;
using System.ComponentModel.Composition;
using System.Runtime.InteropServices;

using SlimDX;
using SlimDX.Direct3D9;
using VVVV.Core.Logging;
using VVVV.PluginInterfaces.V1;
using VVVV.PluginInterfaces.V2;
using VVVV.PluginInterfaces.V2.EX9;
using VVVV.Utils.VColor;
using VVVV.Utils.VMath;
using VVVV.Utils.SlimDX;

#endregion usings

//here you can change the vertex type
using VertexType = VVVV.Utils.SlimDX.SimpleVertex;

namespace VVVV.Nodes
{
	//custom data per graphics device
	public class CustomDeviceData : DeviceData
	{

		//vertex buffer for this device
		public VertexBuffer VB { get; set; }

		public CustomDeviceData(VertexBuffer vb) : base()
		{
			VB = vb;
		}
	}

	#region PluginInfo
	[PluginInfo(Name = "WireBox", Category = "EX9", Help = "Basic template which renders directly into the vvvv Renderer(EX9)", Tags = "")]
	#endregion PluginInfo
	public class EX9WireBoxNode : DXLayerOutPluginBase<CustomDeviceData>, IPluginEvaluate
	{
		#region fields & pins

		[Input("Transform In")]
		IDiffSpread<Matrix> FPinInTransform;

		[Input("WHD", IsSingle=true)]
		IDiffSpread<Vector3> FPinInWHD;

		[Import()]
		ILogger FLogger;

		//slice count
		int FSpreadCount;

		#endregion fields & pins

		// import host and hand it to base constructor
		// the two booleans set whether to create a render state and/or sampler state pin
		[ImportingConstructor()]
		public EX9WireBoxNode(IPluginHost host) : base(host, true, true)
		{
		}

		//called when data for any output pin is requested
		public void Evaluate(int SpreadMax)
		{
			//recreate device data if filename or slice count has changed
			if (FSpreadCount != SpreadMax) {
				FSpreadCount = SpreadMax;
				Reinitialize();
			}
		}

		#region device data handling

		//this method gets called, when Reinitialize() was called in evaluate,
		//or a graphics device asks for its data
		protected override CustomDeviceData CreateDeviceData(Device device)
		{
			FLogger.Log(LogType.Message, "Creating resource...");

			//create a vertex buffer with desired size
			var vb = new VertexBuffer(device, 8 * Marshal.SizeOf(typeof(VertexType)), Usage.WriteOnly, VertexFormat.None, Pool.Managed);

			//return a new device data
			return new CustomDeviceData(vb);
		}

		//this method gets called, when Update() was called in evaluate,
		//or a graphics device asks for its data, here you fill the resources with the actual data
		protected override void UpdateDeviceData(CustomDeviceData deviceData)
		{
			//lock the vertexbuffer and get its data stream
			var stream = deviceData.VB.Lock(0, 0, LockFlags.None);
			
			float W = (float)FPinInWHD[0].X;
			float H = (float)FPinInWHD[0].Y;
			float D = (float)FPinInWHD[0].Z;

			//write the vertex data
			stream.Write(new VertexType(new Vector3(-W,-H,-D)));
			stream.Write(new VertexType(new Vector3(+W,-H,-D)));
			stream.Write(new VertexType(new Vector3(+W,+H,-D)));
			stream.Write(new VertexType(new Vector3(-W,+H,-D)));
			
			stream.Write(new VertexType(new Vector3(-W,-H,+D)));
			stream.Write(new VertexType(new Vector3(+W,-H,+D)));
			stream.Write(new VertexType(new Vector3(+W,+H,+D)));
			stream.Write(new VertexType(new Vector3(-W,+H,+D)));
	
			//unlock the vertex buffer
			deviceData.VB.Unlock();
		}

		//this is called by vvvv to delete the resources of a specific device data
		protected override void DestroyDeviceData(CustomDeviceData deviceData, bool OnlyUnManaged)
		{
			deviceData.VB.Dispose();
		}

		#endregion device data handling

		//render into the vvvv renderer
		protected override void Render(Device device, CustomDeviceData deviceData)
		{
			//enable simple sprite rendering
			device.SetRenderState(RenderState.PointSpriteEnable, true);
			device.SetRenderState(RenderState.PointScaleEnable, true);
			device.SetRenderState(RenderState.PointSize, 0.05f);

			//set vertex buffer
			device.SetStreamSource(0, deviceData.VB, 0, Marshal.SizeOf(typeof(VertexType)));

			//set vertex format
			device.VertexFormat = VertexType.Format;

			for (int i = 0; i < FPinInTransform.SliceCount; i++) {
				//set render state from pin
				FRenderStatePin.SetSliceStates(i);

				//set transform
				device.SetTransform(TransformState.World, FPinInTransform[i]);

				//draw the geometry
				device.DrawPrimitives(PrimitiveType.PointList, 0, FSpreadCount);
			}

		}
	}
}
