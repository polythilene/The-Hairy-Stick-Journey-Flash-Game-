package 
{
	import de.polygonal.core.*;
	
	/**
	 * ...
	 * @author Kurniawan Fitriadi
	 */
	public class CPoolManager
	{
		private var m_pools:Array;
		
		public function CPoolManager() 
		{
			m_pools = [];
		}
		
		public function registerPool(c:Object, initCount:int) : void
		{
			var id:String = c.toString();
			if ( m_pools[id] == null )
			{
				m_pools[id] = new ObjectPool(true);
				m_pools[id].allocate(c, initCount);
			}
		}
		
		public function setPoolData(c:Object, data:*) : void
		{
			var id:String = c.toString();
			if ( m_pools[id] )
			{
				m_pools[id].object = data;
			}
		}
		
		public function getPoolData(c:Object) : * 
		{
			var id:String = c.toString();
			if ( m_pools[id] )
				return m_pools[id].object;
			
			return null;
		}
	}

}