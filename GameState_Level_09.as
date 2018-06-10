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
	public class GameState_Level_09 extends CStickgerinLevel
	{
		static private var m_instance:GameState_Level_09;
		
		public function GameState_Level_09(lock:SingletonLock) {}
		
		
		override protected function prepareScene():void 
		{
			/* setup layer */
			m_sky = new Sky_Level_09;
			m_sky.x = m_sky.y = 0;
			
			m_background = new Background_Level_09;
			m_background.x = m_background.y = 0; 
			m_bgMaxWidth = 2000;
			
			m_foreground = new Foreground_Level_09;
			m_foreground.x = m_foreground.y = 0;
			m_fgMaxWidth = 2100;
			
			/* link slot to clip */
			m_itemSlots[0] = m_foreground.slot_01;
			m_itemSlots[1] = m_foreground.slot_02;
			m_itemSlots[2] = m_foreground.slot_03;
			m_itemSlots[3] = m_foreground.slot_04;
			
			super.prepareScene();
		}
		
		override public function enter():void 
		{
			m_currentLevel = 9;
			setLevelAccess(m_currentLevel);
			
			super.enter();
			
			/* hide actors */
						
			prepareActor( m_foreground.harry_masuk );
			
			prepareActor( m_foreground.harry_tangga_success );
			prepareActor( m_foreground.harry_gergaji_01_fail );
			prepareActor( m_foreground.harry_air_01_fail );
			prepareActor( m_foreground.harry_pisau_01_fail );
			prepareActor( m_foreground.harry_cermin_01_fail );
			
			prepareActor( m_foreground.harry_cermin_success );
			prepareActor( m_foreground.harry_gergaji_02_fail );
			prepareActor( m_foreground.harry_air_02_fail );
			prepareActor( m_foreground.harry_pisau_02_fail );
			
			prepareActor( m_foreground.harry_air_success );
			prepareActor( m_foreground.harry_gergaji_03_fail );
			prepareActor( m_foreground.harry_pisau_03_fail );
			
			prepareActor( m_foreground.harry_pisau_success );
			prepareActor( m_foreground.harry_gergaji_success );
			
			m_foreground.tangga_idle.visible = false;
			m_foreground.peti_idle.visible = false;
			
			
			/* set inventory */
			
			MovieClip(m_itemContainer[0]).gotoAndStop(3);		// slot 1 = tangga
			MovieClip(m_itemContainer[1]).gotoAndStop(22);		// slot 2 = gergaji
			MovieClip(m_itemContainer[2]).gotoAndStop(24);		// slot 3 = air
			MovieClip(m_itemContainer[3]).gotoAndStop(23);		// slot 4 = pisau
			MovieClip(m_itemContainer[4]).gotoAndStop(21);		// slot 5 = cermin
			
			/* listen to event */
			
			m_owner.stage.addEventListener("tangga_success_done", tanggaSuccess);
			m_owner.stage.addEventListener("cermin_success_done", cerminSuccess);
			m_owner.stage.addEventListener("air_success_done", air_success);
			m_owner.stage.addEventListener("gergaji_success_done", gergaji_success);
			m_owner.stage.addEventListener("pisau_success_done", pisau_success);
			
			m_owner.stage.addEventListener("gergaji_01_fail_done", attemptFailed);
			m_owner.stage.addEventListener("air_01_fail_done", attemptFailed);
			m_owner.stage.addEventListener("pisau_01_fail_done", attemptFailed);
			m_owner.stage.addEventListener("cermin_01_fail_done", attemptFailed);
			m_owner.stage.addEventListener("pisau_02_fail_done", attemptFailed);
			m_owner.stage.addEventListener("air_02_fail_done", attemptFailed);
			m_owner.stage.addEventListener("gergaji_02_fail_done", attemptFailed);
			m_owner.stage.addEventListener("gergaji_03_fail_done", attemptFailed);
			m_owner.stage.addEventListener("pisau_03_fail_done", attemptFailed);

			
			/* set actor */
			setActor( m_foreground.harry_masuk );
			
			/* show gui */
			showGUI();
			
			ParticleManager.getInstance().add(CEmitterCaveDust, 0, 0);
			ParticleManager.getInstance().add(CEmitterDessertDust, 0, 0);
			
			setCountdown(80);		// set countdown
			
			/* play music */
			if( m_bgm )	m_bgm.stop();
			m_bgm = SoundManager.getInstance().playMusic("Music_FastTalkin", 1000);
		}
		
		/* SIMULATION STARTING POINT */
		override protected function startSimulation(event:TimerEvent):void 
		{	
			super.startSimulation(event);
			
			/* first check item on slot 1 */
			
			if ( checkSlotItem(0) == 3 )										// TANGGA?		(SUCCESS)
			{	
				/* set actor */
				setActor( m_foreground.harry_tangga_success );
			}
			else if ( checkSlotItem(0) == 22 )									// GERGAJI?		(FAIL)
			{	
				/* set actor */
				setActor( m_foreground.harry_gergaji_01_fail );
			}
			else if ( checkSlotItem(0) == 24 )									// AIR?			(FAIL)
			{	
				/* set actor */
				setActor( m_foreground.harry_air_01_fail );
			}
			else if ( checkSlotItem(0) == 23 )									// PISAU?		(FAIL)
			{	
				/* set actor */
				setActor( m_foreground.harry_pisau_01_fail );
			}
			else if ( checkSlotItem(0) == 21 )									// CERMIN?		(FAIL)
			{	
				/* set actor */
				setActor( m_foreground.harry_cermin_01_fail );
			}
			
			hideSlotItem(0);				
		}
		
		/* SIMULATION COMPLETE */
		override protected function simulationComplete():void 
		{
			super.simulationComplete();
			GameStateManager.getInstance().setState( GameState_Level_10.getInstance() );
		}
		
		/* EVENT ANIMASI */
		
		private function tanggaSuccess(event:Event):void
		{
			m_owner.stage.removeEventListener("tangga_success_done", tanggaSuccess );
			
			m_foreground.tangga_idle.visible = true;
			
			/* now check item on slot 2 */
			
			if ( checkSlotItem(1) == 21 )										// CERMIN?		(SUCCESS)
			{	
				/* set actor */
				setActor( m_foreground.harry_cermin_success, 850 );
				m_foreground.eagle_idle.visible = false;
			}
			else if ( checkSlotItem(1) == 22 )									// GERGAJI?		(FAIL)
			{	
				/* set actor */
				setActor( m_foreground.harry_gergaji_02_fail );
				m_foreground.eagle_idle.visible = false;
			}
			else if ( checkSlotItem(1) == 24 )									// AIR?			(FAIL)
			{	
				/* set actor */
				setActor( m_foreground.harry_air_02_fail );
			}
			else if ( checkSlotItem(1) == 23 )									// PISAU?		(FAIL)
			{	
				/* set actor */
				setActor( m_foreground.harry_pisau_02_fail );
				m_foreground.eagle_idle.visible = false;
			}
			
			hideSlotItem(1);
		}	
			
		private function cerminSuccess(event:Event):void
		{
			m_owner.stage.removeEventListener("cermin_success_done", cerminSuccess );
			
			m_foreground.mumi_idle.visible = false;
			
			/* now check item on slot 3 */
			
			if ( checkSlotItem(2) == 24 )										// AIR?			(SUCCESS)
			{	
				/* set actor */
				setActor( m_foreground.harry_air_success, 1500 );
			}
			else if ( checkSlotItem(2) == 22 )									// GERGAJI?		(FAIL)
			{	
				/* set actor */
				setActor( m_foreground.harry_gergaji_03_fail );
			}
			else if ( checkSlotItem(2) == 23 )									// PISAU?		(FAIL)
			{	
				/* set actor */
				setActor( m_foreground.harry_pisau_03_fail );
			}
			
			hideSlotItem(2);
		}	
		
		private function air_success(event:Event):void
		{
			m_owner.stage.removeEventListener("air_success_done", air_success );
			
			m_foreground.peti_idle.visible = true;
			
			/* now check item on slot 4 */
			
			m_foreground.kaktus_idle.visible = false;
			
			if ( checkSlotItem(3) == 22 )									// GERGAJI?		(SUCCESS)
			{	
				/* set actor */
				setActor( m_foreground.harry_gergaji_success );
			}
			else if ( checkSlotItem(3) == 23 )								// PISAU?		(SUCCESS)
			{	
				/* set actor */
				setActor( m_foreground.harry_pisau_success );
			}
			
			hideSlotItem(3);
		}	
		
		private function gergaji_success(event:Event):void
		{
			m_owner.stage.removeEventListener("gergaji_success_done", gergaji_success );
			simulationComplete();
			
			/* BEING EVIL */
			if ( !GlobalData.achievementBeingEvil )
			{
				GlobalData.achievementBeingEvil = true;
				achievementMessage(	GlobalData.achievementString["beingEvil"][0],
									GlobalData.achievementString["beingEvil"][1] );
			}
			
			unlockNewgroundsMedal("Being Evil");
		}	
		
		private function pisau_success(event:Event):void
		{
			m_owner.stage.removeEventListener("pisau_success_done", pisau_success );
			simulationComplete();
		}	
		
		private function attemptFailed(event:Event):void
		{
			m_owner.stage.removeEventListener("gergaji_01_fail_done", attemptFailed);
			m_owner.stage.removeEventListener("air_01_fail_done", attemptFailed);
			m_owner.stage.removeEventListener("pisau_01_fail_done", attemptFailed);
			m_owner.stage.removeEventListener("cermin_01_fail_done", attemptFailed);
			m_owner.stage.removeEventListener("pisau_02_fail_done", attemptFailed);
			m_owner.stage.removeEventListener("air_02_fail_done", attemptFailed);
			m_owner.stage.removeEventListener("gergaji_02_fail_done", attemptFailed);
			m_owner.stage.removeEventListener("gergaji_03_fail_done", attemptFailed);
			m_owner.stage.removeEventListener("pisau_03_fail_done", attemptFailed);
			
			gameOver( (event.type.toString() != "cermin_01_fail_done" &&
					   event.type.toString() != "air_01_fail_done") ); 
					   
			/* BEING EVIL */
			if ( !GlobalData.achievementBeingEvil )
			{
				GlobalData.achievementBeingEvil = true;
				achievementMessage(	GlobalData.achievementString["beingEvil"][0],
									GlobalData.achievementString["beingEvil"][1] );
			}
			
			unlockNewgroundsMedal("Being Evil");
		}
			
		/* ============================
		 * 			SINGLETON
		 * ============================
		 */
		
		static public function getInstance(): GameState_Level_09
		{
			if( m_instance == null ){
				m_instance = new GameState_Level_09( new SingletonLock() );
			}
			return m_instance;
		}
	}
}

class SingletonLock{}