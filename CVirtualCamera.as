package  
{
	import flash.geom.Point;
	/**
	 * ...
	 * @author ...
	 */
	public class CVirtualCamera extends VirtualCamera
	{
	
		protected var m_lastTarget:Point;
		
		public function CVirtualCamera() 
		{
			m_lastTarget = new Point();
		}
		
		public function setCameraTarget(pos_x:Number, pos_y:Number):void
		{
			x = pos_x;
			y = pos_y;
		}
		
		public function getLastTargetPointOffsetX():int
		{
			return Math.floor(x - m_lastTarget.x);
		}
		
		public function getLastTargetPointOffsetY():int
		{
			return Math.floor(y - m_lastTarget.y);
		}
		
		override public function set x(value:Number):void
		{
			super.x = value;	
			m_lastTarget.x = value;
		}
		
		override public function set y(value:Number):void
		{
			super.y = value;
			m_lastTarget.y = value;
		}
		
	}
}