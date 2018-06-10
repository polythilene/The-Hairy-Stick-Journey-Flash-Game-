package  
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	
	import gs.TweenMax;
		
	/**
	 * ...
	 * @author Wiwit
	 */
	public class GameState_Level_02 extends CStickgerinLevel
	{
		static private var m_instance:GameState_Level_02;
		
		public function GameState_Level_02(lock:SingletonLock) { }
		
		
		override protected function prepareScene():void 
		{
			/* setup layer */
			m_sky = new Sky_Level_02;
			m_sky.x = 0;
			m_sky.y = 0;
						
			m_background = new Background_Level_02;
			m_background.x = m_background.y = 0;
			m_bgMaxWidth = 1100;
			
			m_foreground = new Foreground_Level_02;
			m_foreground.x = m_foreground.y = 0;
			m_fgMaxWidth = 1200;
			
			/* link slot to clip */
			m_itemSlots[0] = m_foreground.slot_01;
			m_itemSlots[1] = m_foreground.slot_02;
			m_itemSlots[2] = m_foreground.slot_03;
			
			super.prepareScene();
		}
		
		override public function enter():void 
		{
			/* set level id */
			m_currentLevel = 2;
			setLevelAccess(m_currentLevel);
			
			super.enter();
			
			/* hide actors */
			prepareActor( m_foreground.harry_kampak_batu );
			prepareActor( m_foreground.harry_jatuh_dari_tangga );
			prepareActor( m_foreground.harry_ungkit_batu );
			prepareActor( m_foreground.harry_naik_tangga );
			prepareActor( m_foreground.harry_tebang_fail );
			prepareActor( m_foreground.harry_tebang_kayu );
						
			/* set inventory */
			MovieClip(m_itemContainer[0]).gotoAndStop(3);		// slot 1 = tangga
			MovieClip(m_itemContainer[1]).gotoAndStop(4);		// slot 2 = pengungkit
			MovieClip(m_itemContainer[2]).gotoAndStop(5);		// slot 3 = kampak
			
			m_foreground.batu_jatuh.visible = false;
			m_foreground.tangga_tebing.visible = false;
			m_foreground.tangga_nyender.visible = false;
			
			
			/* listen to event */
			m_owner.stage.addEventListener("ungkit_success_end", ungkitSuccessEnd);
			m_owner.stage.addEventListener("tangga_success_end", tanggaSuccessEnd);
			m_owner.stage.addEventListener("tebang_success_end", tebangSuccessEnd);
			
			m_owner.stage.addEventListener("kampak_fail_end", attemptFailed);
			m_owner.stage.addEventListener("tangga_fail_end", attemptFailed);
			m_owner.stage.addEventListener("tebang_fail_end", attemptFailed);
			
			/* show GUI */
			m_cutScene = false;
			setCountdown(60);
			showGUI();
			
			/* set actor */
			setActor(m_foreground.harry_mikir);
			
			/* set environment particle */
			ParticleManager.getInstance().add(CEmitterForestMist, 0, 0);
			
			/* set ingame credits */
			InGameCredits.getInstance().attach(m_owner); 
			InGameCredits.getInstance().addCredit("Framework & Level Programmer", "Kurniawan Fitriadi");
			InGameCredits.getInstance().addCredit("Level Programmer", "Matthius Andy");
			InGameCredits.getInstance().addCredit("Animation & Interface", "Andrea Perdana");
			InGameCredits.getInstance().addCredit("Animation", "Aditya Sumantri");
			InGameCredits.getInstance().addCredit("Additional Artist", "Ronny Hardianto");
			InGameCredits.getInstance().addCredit("Sound Editor", "Agung C Putro");
			InGameCredits.getInstance().addCredit("Music Composer", "Kevin MacLeod");
			
			if( !m_bgm )
				m_bgm = SoundManager.getInstance().playMusic("Music_FastTalkin", 1000);
		}
		
		override public function update(elapsedTime:int):void 
		{
			super.update(elapsedTime);
			InGameCredits.getInstance().update(elapsedTime);
		}
		
		override public function exit():void 
		{
			InGameCredits.getInstance().clear();
			InGameCredits.getInstance().detach(); 
			super.exit();
		}
		
		/* SIMULATION STARTING POINT */
		override protected function startSimulation(event:TimerEvent):void 
		{	
			super.startSimulation(event);
			
			/* first check item on slot 1 */
			if ( checkSlotItem(0) == 4 )									// UNGKIT?		(SUCCESS)
			{
				/* set actor */
				setActor(m_foreground.harry_ungkit_batu);
				m_foreground.batu_idle.visible = false;
			}
			else if ( checkSlotItem(0) == 3 )								// TANGGA?		(FAIL)
			{
				/* set actor */
				setActor(m_foreground.harry_jatuh_dari_tangga);
			}
			else if ( checkSlotItem(0) == 5 )								// KAMPAK?		(FAIL)
			{
				/* set actor */
				setActor(m_foreground.harry_kampak_batu);
			}
			
			hideSlotItem(0);				
		}
		
		/* SIMULATION COMPLETE */
		override protected function simulationComplete():void 
		{
			super.simulationComplete();
			GameStateManager.getInstance().setState( GameState_Level_03.getInstance() );
		}
		
		/* EVENT ANIMASI */
		
		private function ungkitSuccessEnd(event:Event):void	
		{
			m_owner.stage.removeEventListener("ungkit_success_end", ungkitSuccessEnd);
			
			m_foreground.batu_jatuh.visible = true;
			
			if ( checkSlotItem(1) == 5 )									// KAMPAK?		(FAIL)
			{
				/* set actor */
				setActor(m_foreground.harry_tebang_fail);
			}
			else if ( checkSlotItem(1) == 3 )								// TANGGA?		(SUCCESS)
			{
				/* set actor */
				setActor(m_foreground.harry_naik_tangga);
			}
			
			hideSlotItem(1);
		}
		
		private function tanggaSuccessEnd(event:Event):void	
		{
			m_owner.stage.removeEventListener("tangga_success_end", tanggaSuccessEnd);
			
			m_foreground.tangga_tebing.visible = true;
			
			setActor(m_foreground.harry_tebang_kayu);
			m_foreground.pohon_stay.visible = false;
			hideSlotItem(2);
		}
		
		private function tebangSuccessEnd(event:Event):void	
		{
			m_owner.stage.removeEventListener("tebang_success_end", tebangSuccessEnd);
			simulationComplete()
		}
		
		private function attemptFailed(event:Event):void
		{
			m_owner.stage.removeEventListener("kampak_fail_end", attemptFailed);
			m_owner.stage.removeEventListener("tangga_fail_end", attemptFailed);
			m_owner.stage.removeEventListener("tebang_fail_end", attemptFailed);
			
			gameOver(true);
		}
		
		/* ============================
		 * 			SINGLETON
		 * ============================
		 */
		
		static public function getInstance(): GameState_Level_02
		{
			if( m_instance == null ){
				m_instance = new GameState_Level_02( new SingletonLock() );
			}
			return m_instance;
		}
	}
}

class SingletonLock{}