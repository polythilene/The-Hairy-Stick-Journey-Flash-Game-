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
	public class GameState_Level_03 extends CStickgerinLevel
	{
		static private var m_instance:GameState_Level_03;
		
		public function GameState_Level_03(lock:SingletonLock) {}
		
		
		override protected function prepareScene():void 
		{
			/* setup layer */
			m_sky = new Sky_Level_03;
			m_sky.x = 0;
			m_sky.y = 0;
						
			m_background = new Background_Level_03;
			m_background.x = m_background.y = 0;
			m_bgMaxWidth = 1000;
			
			m_foreground = new Foreground_Level_03;
			m_foreground.x = m_foreground.y = 0;
			m_fgMaxWidth = 1150;
			
			/* link slot to clip */
			m_itemSlots[0] = m_foreground.slot_01;
			m_itemSlots[1] = m_foreground.slot_02;
			
			super.prepareScene();
		}
		
		override public function enter():void 
		{
			/* set level id */
			m_currentLevel = 3;
			setLevelAccess(m_currentLevel);
			
			super.enter();
			
			/* hide actors */
			prepareActor( m_foreground.harry_mikir );
			prepareActor( m_foreground.harry_masuk_meriam_01  );
			prepareActor( m_foreground.harry_naik_tangga  );
			prepareActor( m_foreground.harry_manjat_tebing  );
			prepareActor( m_foreground.harry_nyebrang_tangga  );
			prepareActor( m_foreground.harry_lompat_tebing  );
			prepareActor( m_foreground.harry_masuk_meriam_02  );
			
			/* set inventory */
			MovieClip(m_itemContainer[0]).gotoAndStop(7);		// slot 1 = meriam
			MovieClip(m_itemContainer[1]).gotoAndStop(3);		// slot 2 = tangga
			MovieClip(m_itemContainer[2]).gotoAndStop(6);		// slot 3 = pasak
			
			/* listen to event */
			m_owner.stage.addEventListener("naik_tangga_succes_end", naikTanggaSuccessEnd);
			m_owner.stage.addEventListener("panjat_tebing_success_end", panjatTebingSuccessEnd);
			m_owner.stage.addEventListener("nyebrang_tangga_success_end", sebrangTanggaSuccessEnd);
			
			m_owner.stage.addEventListener("canon_01_fail_end", attemptFailed);
			m_owner.stage.addEventListener("canon_02_fail_end", attemptFailed);
			m_owner.stage.addEventListener("harry_lompat_tebing_fail_end", attemptFailed);
			
			/* set actor */
			setActor(m_foreground.harry_mikir);
			
			/* show gui */
			showGUI();
			
			/* set countdown */
			setCountdown(60);
			
			/* set environment particle */
			ParticleManager.getInstance().add(CEmitterForestMist, 0, 0);
			
			setCountdown(60);		// set countdown
			
			if( !m_bgm )
				m_bgm = SoundManager.getInstance().playMusic("Music_FastTalkin", 1000);
		}
		
		/* SIMULATION STARTING POINT */
		override protected function startSimulation(event:TimerEvent):void 
		{	
			super.startSimulation(event);
			
			/* first check item on slot 1 */
			
			if ( checkSlotItem(0) == 3 )									// TANGGA?		(SUCCESS)
			{
				/* set actor */
				setActor(m_foreground.harry_naik_tangga);
			}
			else if ( checkSlotItem(0) == 6 )								// PANJAT?		(SUCCESS)
			{
				/* set actor */
				setActor(m_foreground.harry_manjat_tebing);
			}
			else if ( checkSlotItem(0) == 7 )								// MERIAM?		(FAIL)
			{
				/* set actor */
				setActor(m_foreground.harry_masuk_meriam_01);			
			}
			
			hideSlotItem(0);				
		}
		
		/* SIMULATION COMPLETE */
		override protected function simulationComplete():void 
		{
			super.simulationComplete();
			GameStateManager.getInstance().setState( GameState_Level_04.getInstance() );
		}
		
		/* EVENT ANIMASI */
		
		private function naikTanggaSuccessEnd(event:Event):void
		{
			m_owner.stage.removeEventListener("naik_tangga_succes_end", naikTanggaSuccessEnd );
			
			/* check slot 2 */
			
			if ( checkSlotItem(1) == 6 )									// PASAK?		(FAIL)
			{
				/* set actor */
				setActor(m_foreground.harry_lompat_tebing);
			}
			else if ( checkSlotItem(1) == 7 )								// MERIAM?		(FAIL)
			{
				/* set actor */
				setActor(m_foreground.harry_masuk_meriam_02, 800);			
			}
			
			hideSlotItem(1);
		}
		
		private function panjatTebingSuccessEnd(event:Event):void
		{
			m_owner.stage.removeEventListener("panjat_tebing_success_end", panjatTebingSuccessEnd );
			
			/* check slot 2 */
			
			if ( checkSlotItem(1) == 3 )									// TANGGA?		(SUCCESS)
			{
				/* set actor */
				setActor(m_foreground.harry_nyebrang_tangga, 770);
			}
			else if ( checkSlotItem(1) == 7 )								// MERIAM?		(MERIAM)
			{
				/* set actor */
				setActor(m_foreground.harry_masuk_meriam_02, 770);			
			}
			
			hideSlotItem(1);
		}
		
		private function sebrangTanggaSuccessEnd(event:Event):void
		{
			m_owner.stage.removeEventListener("nyebrang_tangga_success_end", sebrangTanggaSuccessEnd );
			
			simulationComplete();
		}
		
		private function attemptFailed(event:Event):void
		{
			m_owner.stage.removeEventListener("canon_01_fail_end", attemptFailed);
			m_owner.stage.removeEventListener("canon_02_fail_end", attemptFailed);
			m_owner.stage.removeEventListener("harry_lompat_tebing_fail_end", attemptFailed);
		
			gameOver(true);
		}
		
		
		/* ============================
		 * 			SINGLETON
		 * ============================
		 */
		
		static public function getInstance(): GameState_Level_03
		{
			if( m_instance == null ){
				m_instance = new GameState_Level_03( new SingletonLock() );
			}
			return m_instance;
		}
	}
}

class SingletonLock{}