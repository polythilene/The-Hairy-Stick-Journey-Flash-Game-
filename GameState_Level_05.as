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
	public class GameState_Level_05 extends CStickgerinLevel
	{
		static private var m_instance:GameState_Level_05;
		
		public function GameState_Level_05(lock:SingletonLock) {}
		
		
		override protected function prepareScene():void 
		{
			/* setup layer */
			m_sky = new Sky_Level_05;
			m_sky.x = 0;
			m_sky.y = 0;
						
			m_background = new Background_Level_05;
			m_background.x = m_background.y = 0; 
			m_bgMaxWidth = 1000;
			
			m_foreground = new Foreground_Level_05;
			m_foreground.x = m_foreground.y = 0;
			m_fgMaxWidth = 1400;
			
			/* link slot to clip */
			m_itemSlots[0] = m_foreground.slot_01;
			m_itemSlots[1] = m_foreground.slot_02;
			m_itemSlots[2] = m_foreground.slot_03;
			
			super.prepareScene();
		}
		
		override public function enter():void 
		{
			/* set level parameters */
			m_currentLevel = 5;
			setLevelAccess(m_currentLevel);
			
			super.enter();
			
			/* hide actors */
			prepareActor( m_foreground.harry_masuk);
			prepareActor( m_foreground.harry_bacok );
			prepareActor( m_foreground.harry_pasang_tangga  );
			prepareActor( m_foreground.harry_pasang_trap  );
			prepareActor( m_foreground.harry_lempar_TNT  );
			prepareActor( m_foreground.harry_nyebrang  );
			prepareActor( m_foreground.harry_terjun_TNT  );
			prepareActor( m_foreground.harry_terjun_kapak  );
			prepareActor( m_foreground.harry_terjun_trap  );
			prepareActor( m_foreground.harry_timpuk_TNT  );
			prepareActor( m_foreground.harry_lempar_trap  );
			prepareActor( m_foreground.harry_lempar_kapak  );
			
			/* set inventory */
			MovieClip(m_itemContainer[0]).gotoAndStop(10);		// slot 1 = perangkap
			MovieClip(m_itemContainer[1]).gotoAndStop(5);		// slot 2 = kampak
			MovieClip(m_itemContainer[2]).gotoAndStop(3);		// slot 3 = tangga
			MovieClip(m_itemContainer[3]).gotoAndStop(9);		// slot 4 = TNT
			
			/* listen to event */
			m_owner.stage.addEventListener("enter_stage_done", enterStageDone );
			m_owner.stage.addEventListener("kapak_success_done", kapakSuccessDone );
			m_owner.stage.addEventListener("pasang_TNT_success_01_done", TNTSuccessDone01 );
			m_owner.stage.addEventListener("nyebrang_success_done", nyebrangSuccessDone );
			m_owner.stage.addEventListener("lempar_trap_success_done", lemparTrapSuccessDone );
			m_owner.stage.addEventListener("lempar_TNT_success_done", lemparTNTSuccessDone );
			
			m_owner.stage.addEventListener("pasang_tangga_fail_done", attemptFailed);
			m_owner.stage.addEventListener("pasang_trap_fail_done", attemptFailed);
			m_owner.stage.addEventListener("terjun_trap_fail_done", attemptFailed);
			m_owner.stage.addEventListener("terjun_kapak_fail_done", attemptFailed);
			m_owner.stage.addEventListener("terjun_TNT_fail_done", attemptFailed);
			m_owner.stage.addEventListener("lempar_kapak_fail_done", attemptFailed);
			
			/* set actor */
			setActor(m_foreground.harry_masuk);
			
			/* start */
			showGUI();
			m_cutScene = false;
			setCountdown(60);
			
			ParticleManager.getInstance().add(CEmitterFallingLeaves, 0, 0);
			ParticleManager.getInstance().add(CEmitterFireFlies, 0, 0);
			
			setCountdown(60);		// set countdown
			
			if( m_bgm ) m_bgm.stop();
			m_bgm = SoundManager.getInstance().playMusic("Music_DancesAndDames", 1000);
		}
		
		/* SIMULATION STARTING POINT */
		override protected function startSimulation(event:TimerEvent):void 
		{	
			super.startSimulation(event);
			
			/* first check item on slot 1 */
			
			if ( checkSlotItem(0) == 3 )									// TANGGA?		(FAIL)
			{
				/* set actor */
				m_foreground.plantIdle.visible = false;
				setActor(m_foreground.harry_pasang_tangga);
			}
			else if ( checkSlotItem(0) == 9 )								// TNT?		  (SUCCESS)
			{
				/* set actor */
				m_foreground.plantIdle.visible = false;
				setActor(m_foreground.harry_lempar_TNT);
			}
			else if ( checkSlotItem(0) == 10 )								// TRAP?		(FAIL)
			{
				/* set actor */
				setActor(m_foreground.harry_pasang_trap);		
			}
			else if ( checkSlotItem(0) == 5 ){
				/* set actor */
				m_foreground.plantIdle.visible = false;
				setActor(m_foreground.harry_bacok);							// KAPAK  (SUCCESS)
			}
			
			hideSlotItem(0);				
		}
		
		/* SIMULATION COMPLETE */
		override protected function simulationComplete():void 
		{
			super.simulationComplete();
			GameStateManager.getInstance().setState( GameState_Level_06.getInstance() );
		}
		
		/* EVENT ANIMASI */
		private function kapakSuccessDone(event:Event):void {
			m_owner.stage.removeEventListener("kapak_success_done", kapakSuccessDone)
			
			/* check slot 2 */
			
			if ( checkSlotItem(1) == 3 )									// TANGGA?		(SUCCESS)
			{
				/* set actor */
				setActor(m_foreground.harry_nyebrang);
			}
			else if ( checkSlotItem(1) == 10 )								// TRAP?		(FAIL)
			{
				/* set actor */
				setActor(m_foreground.harry_terjun_trap);			
			}
			else if ( checkSlotItem(1) == 9) 								// TNT  (FAIL)
			{
				/* set actor */
				setActor(m_foreground.harry_terjun_TNT)
			}
			
			hideSlotItem(1);
		}
		
		private function enterStageDone(event:Event):void {
			/*remove listener*/
			m_owner.stage.removeEventListener("enter_stage_done", enterStageDone);
		}
		
		private function TNTSuccessDone01(event:Event):void
		{
			m_owner.stage.removeEventListener("pasang_TNT_success_01_done", TNTSuccessDone01 );
			
			/* check slot 2 */
			
			if ( checkSlotItem(1) == 3 )									// TANGGA?		(SUCCESS)
			{
				/* set actor */
				setActor(m_foreground.harry_nyebrang);
			}
			else if ( checkSlotItem(1) == 10 )								// TRAP?		(FAIL)
			{
				/* set actor */
				setActor(m_foreground.harry_terjun_trap);			
			}
			else if ( checkSlotItem(1) == 5) 								// KAPAK  (FAIL)
			{
				/* set actor */
				setActor(m_foreground.harry_terjun_kapak)
			}
			
			hideSlotItem(1);
		}
		
		private function nyebrangSuccessDone(event:Event):void
		{
			m_owner.stage.removeEventListener("nyebrang_success_done", nyebrangSuccessDone );
			
			if ( checkSlotItem(2) == 5 )									// KAPAK?		(FAIL)
			{
				/* set actor */
				setActor(m_foreground.harry_lempar_kapak);
			}
			else if ( checkSlotItem(2) == 10 )								// TRAP?		(SUCCESS)
			{
				/* set actor */
				setActor(m_foreground.harry_lempar_trap);			
			}
			else if ( checkSlotItem(2) == 9) 								// TNT  (SUCCESS)
			{
				/* set actor */
				setActor(m_foreground.harry_timpuk_TNT)
			}
			
			hideSlotItem(2);
		}
		
		private function lemparTrapSuccessDone(event:Event):void
		{
			m_owner.stage.removeEventListener("lempar_trap_success_done", lemparTrapSuccessDone);
			
			simulationComplete();
		}
		
		private function lemparTNTSuccessDone(event:Event):void
		{
			m_owner.stage.removeEventListener("lempar_TNT_success_done", lemparTNTSuccessDone)
			
			simulationComplete();
		}
		
		private function attemptFailed(event:Event):void
		{
			m_owner.stage.removeEventListener("pasang_tangga_fail_done", attemptFailed);
			m_owner.stage.removeEventListener("pasang_trap_fail_done", attemptFailed);
			m_owner.stage.removeEventListener("terjun_trap_fail_done", attemptFailed);
			m_owner.stage.removeEventListener("terjun_kapak_fail_done", attemptFailed);
			m_owner.stage.removeEventListener("terjun_TNT_fail_done", attemptFailed);
			m_owner.stage.removeEventListener("lempar_kapak_fail_done", attemptFailed);
			
			gameOver( (event.type.toString() != "pasang_trap_fail_done") );
		}
			
		/* ============================
		 * 			SINGLETON
		 * ============================
		 */
		
		static public function getInstance(): GameState_Level_05
		{
			if( m_instance == null ){
				m_instance = new GameState_Level_05( new SingletonLock() );
			}
			return m_instance;
		}
	}
}

class SingletonLock{}