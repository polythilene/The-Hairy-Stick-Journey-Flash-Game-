package  
{
	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
		
	/**
	 * ...
	 * @author Wiwit
	 */
	public class GameState_ArmorGamesLogo extends CGameState
	{
		static private var m_instance:GameState_ArmorGamesLogo;
		
		public function GameState_ArmorGamesLogo(lock:SingletonLock) {}
		
		
		/* objects */
		private var mc_ScreenOpeningLogo:ArmorGamesSplash;
		private var delay:int;
		
		override public function enter():void 
		{
			delay = 7000;
			
			mc_ScreenOpeningLogo = new ArmorGamesSplash();
			m_owner.addChild(mc_ScreenOpeningLogo);
			
			mc_ScreenOpeningLogo.x = 400;
			mc_ScreenOpeningLogo.y = 200;
			mc_ScreenOpeningLogo.gotoAndPlay(1);
			mc_ScreenOpeningLogo.buttonMode = mc_ScreenOpeningLogo.useHandCursor = true;
			
			mc_ScreenOpeningLogo.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		override public function exit():void 
		{
			mc_ScreenOpeningLogo.removeEventListener(MouseEvent.CLICK, onClick);
			m_owner.removeChild(mc_ScreenOpeningLogo);
			mc_ScreenOpeningLogo = null;
		}
		
		private function onClick(event:MouseEvent):void
		{
			navigateTo("http://www.armorgames.com/");
		}
		
		override public function update(elapsedTime:int):void 
		{
			delay -= elapsedTime;
			
			if (delay <= 0)
			{
				GameStateManager.getInstance().setState(GameState_BGLogo.getInstance());
			}
		}
		
		
		/* ============================
		 * 			SINGLETON
		 * ============================
		 */
		
		static public function getInstance(): GameState_ArmorGamesLogo
		{
			if( m_instance == null ){
				m_instance = new GameState_ArmorGamesLogo( new SingletonLock() );
			}
			return m_instance;
		}
	}
}

class SingletonLock{}