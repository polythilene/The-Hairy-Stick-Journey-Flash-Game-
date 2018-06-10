package  
{
	import flash.display.DisplayObjectContainer;
	import gs.TweenMax;
		
	/**
	 * ...
	 * @author Wiwi
	 */
	public class CCreditsItem extends InGameCreditsText
	{
		public var prev:CCreditsItem;
		public var next:CCreditsItem;
		
		private var m_alive:Boolean;
		private var m_lifeTime:int;
		private var m_container:DisplayObjectContainer;
		private var m_fadeOut:Boolean;
		
		public function CCreditsItem() { }
		
		private function randomRange(minNum:Number, maxNum:Number):Number  
		{
			return ( Math.random() * (maxNum - minNum + 1) + minNum );
		}
		
		public function reset(container:DisplayObjectContainer, creditTitle:String, creditName:String, lifeTime:int=10000):void
		{
			m_container = container;
			m_container.addChild(this);
			
			m_alive = true;
			textTitle.htmlText = creditTitle;
			textName.htmlText = creditName;
			m_lifeTime = lifeTime;
			m_fadeOut = false;
			
			x = 800;
			y = randomRange(100, 300);
			alpha = 0;
			TweenMax.to( this, 2, { alpha:0.9 } );
		}
		
		public function remove():void
		{
			TweenMax.killTweensOf(this);
			m_container.removeChild(this);
			m_container = null;
		}
		
		public function update(elapsedTime:int):void
		{
			m_lifeTime -= elapsedTime;
			
			x -= elapsedTime * 0.02;
			
			if ( m_lifeTime < 3000 && m_fadeOut == false )
			{
				m_fadeOut = true;
				TweenMax.to(this, 2, { alpha:0 } );
			}
			
			if ( m_lifeTime < 0 )
			{
				m_alive = false;
			}
		}
		
		public function isAlive():Boolean
		{
			return m_alive;
		}
		
		public function setDead():void
		{
			m_alive = false;
		}
	}

}