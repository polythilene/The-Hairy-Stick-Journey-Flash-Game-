package
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.utils.getQualifiedClassName;
	

	/**
	 * ...
	 * @author Kurniawan Fitriadi
	 */
	public class InGameCredits extends EventDispatcher
	{
		static private var m_instance:InGameCredits;
		static private const DELAY:int = 7000;
		
		private var m_head:CCreditsItem;
		private var m_tail:CCreditsItem;
		
		private var m_creditTitles:Array;
		private var m_creditNames:Array;
		private var m_currIndex:int;
		private var m_delayCount:int;
		
		private var m_creditContainer:Sprite;
		private var m_container:DisplayObjectContainer;
		private var m_poolManager:CPoolManager;
		
		public function InGameCredits(lock:SingletonLock)	
		{ 
			m_creditTitles = [];
			m_creditNames = [];
			m_currIndex = 0;
			
			m_delayCount = DELAY >> 1;
			
			m_poolManager = new CPoolManager();
			m_poolManager.registerPool(CCreditsItem, 5);
			
			m_creditContainer = new Sprite();
			m_creditContainer.mouseChildren = false;
			m_creditContainer.mouseEnabled = false;
		}
		
		public function attach(container:DisplayObjectContainer):void
		{
			m_container = container;
			m_container.addChild(m_creditContainer);
		}
		
		public function detach():void
		{
			if( m_container )
				m_container.removeChild(m_creditContainer);
				
			m_container = null;
		}
		
		public function addCredit(title:String, name:String):void
		{
			m_creditTitles.push(title);
			m_creditNames.push(name);
		}
		
		public function update(elapsedTime:int):void
		{
			m_delayCount -= elapsedTime;
			
			
			if( m_delayCount < 0 && m_currIndex < m_creditTitles.length )
			{
				m_delayCount = DELAY;
				
				var item:CCreditsItem = m_poolManager.getPoolData(CCreditsItem);
				item.reset(m_creditContainer, m_creditTitles[m_currIndex], m_creditNames[m_currIndex]);
				
				m_currIndex++;
				
				// add to list
				if( m_head == null )
				{
					m_head = item;
					m_tail = item;
				}
				else
				{
					m_tail.next = item;
					item.prev = m_tail;
					m_tail = item;
				}
			}
			
			/* update items */
			var creditItem:CCreditsItem = m_head;
			
			while( creditItem != null ) 
			{
				if( creditItem.isAlive() )
				{
					creditItem.update(elapsedTime);
					creditItem = creditItem.next;
				}
				else	
				{
					var garbage:CCreditsItem = creditItem;
					creditItem = creditItem.next;
						
					remove(garbage);
					sendToPool(garbage);
				}
			}
		}
		
		public function clear(): void
		{
			m_currIndex = 0;
			m_delayCount = DELAY >> 1;
			
			if ( m_creditTitles.length > 0 )	m_creditTitles.splice(0, m_creditTitles.length);
			if ( m_creditNames.length > 0 ) 	m_creditNames.splice(0, m_creditNames.length);
		
			/* send all item to pool */
			var item:CCreditsItem = m_head;
			while( item != null ) 
			{
				item.setDead();
					
				var garbage:CCreditsItem = item;
				item = item.next;
				
				remove(garbage);
				sendToPool(garbage);
			}
		}
		
		public function remove(item:CCreditsItem): void
		{
			item.remove();
			
			/* check if object is a list head */
			if( item.prev == null )
			{
				if( item.next != null )
				{
					m_head = item.next;
					item.next.prev = null;
					item.next = null;
				}
				else 
				{
					m_head = null;
					m_tail = null;
				}
			}
			
			/* check if object is a list body */
			else if( item.prev != null && item.next != null )
			{
				// this is a body
				item.prev.next = item.next;
				item.next.prev = item.prev;
				
				item.prev = null;
				item.next = null;
			}
			
			/* check if object is a list tail */
			else if( item.next == null )
			{
				if (item.prev != null) 
				{
					// this is the tail
					m_tail = item.prev;
					item.prev.next = null;
					item.prev = null;
				}
			}
		}
		
		private function sendToPool(emitter:CCreditsItem): void
		{
			/* send object to pool */
			m_poolManager.setPoolData(CCreditsItem, emitter);
		}
			
		static public function getInstance(): InGameCredits
		{
			if( m_instance == null ){
				m_instance = new InGameCredits( new SingletonLock() );
			}
			return m_instance;
		}
	}
}

class SingletonLock{}