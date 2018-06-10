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
	public class GameState_Level_10 extends CStickgerinLevel
	{
		static private var m_instance:GameState_Level_10;
		
		public function GameState_Level_10(lock:SingletonLock) {}
		
		
		override protected function prepareScene():void 
		{
			/* setup layer */
			m_sky = new Sky_Level_10;
			m_sky.x = m_sky.y = 0;
			
			m_background = new Background_Level_10;
			m_background.x = m_background.y = 0; 
			m_bgMaxWidth = 2050;
			
			m_foreground = new Foreground_Level_10;
			m_foreground.x = m_foreground.y = 0;
			m_fgMaxWidth = 2400;
			
			/* link slot to clip */
			m_itemSlots[0] = m_foreground.slot_01;
			m_itemSlots[1] = m_foreground.slot_02;
			m_itemSlots[2] = m_foreground.slot_03;
			m_itemSlots[3] = m_foreground.slot_04;
			
			super.prepareScene();
		}
		
		override public function enter():void 
		{
			m_currentLevel = 10;
			setLevelAccess(m_currentLevel);
			
			super.enter();
			
			/* hide actors */
			
			prepareActor( m_foreground.Harry_Masuk );
			
			prepareActor( m_foreground.Harry_Flame_Success );
			prepareActor( m_foreground.Harry_Cermin_01_Fail );
			prepareActor( m_foreground.Harry_Granat_01_Fail );
			prepareActor( m_foreground.Harry_Meriam_01_Fail );
			
			prepareActor( m_foreground.Harry_Granat_01_Success );
			prepareActor( m_foreground.Harry_Meriam_Success );
			//prepareActor( m_foreground.Harry_Cermin_02_Fail );
			prepareActor( m_foreground.Harry_Cermin_02_Success );
			
			prepareActor( m_foreground.Harry_Granat_02_Success );
			prepareActor( m_foreground.Harry_Cermin_03_Fail );
			prepareActor( m_foreground.Harry_Meriam_03_Fail );
			
			prepareActor( m_foreground.Harry_Cermin_Success );
			prepareActor( m_foreground.Harry_Meriam_04_Fail );
			
			/* set inventory */
			
			MovieClip(m_itemContainer[0]).gotoAndStop(7);		// slot 1 = meriam
			MovieClip(m_itemContainer[1]).gotoAndStop(21);		// slot 2 = cermin
			MovieClip(m_itemContainer[2]).gotoAndStop(25);		// slot 3 = granat
			MovieClip(m_itemContainer[3]).gotoAndStop(26);		// slot 4 = flame
			
			
			/* listen to event */
			
			m_owner.stage.addEventListener("Flame_Success_done", flameSuccess);
			

			m_owner.stage.addEventListener("Granat_01_Success_done", granat01Success);
			m_owner.stage.addEventListener("Meriam_Success_done", meriamSuccess);
			m_owner.stage.addEventListener("Granat_02_Success_done", granat02Success);
			m_owner.stage.addEventListener("Cermin_Success_done", cerminSuccess);
			
			m_owner.stage.addEventListener("Cermin_01_Fail_done", attemptFailed);
			m_owner.stage.addEventListener("Granat_01_Fail_done", attemptFailed);
			m_owner.stage.addEventListener("Meriam_01_Fail_done", attemptFailed);
			m_owner.stage.addEventListener("Cermin_02_Success_done", cermin02Success);
			
			m_owner.stage.addEventListener("Cermin_03_Fail_done", attemptFailed);
			m_owner.stage.addEventListener("Meriam_03_Fail_done", attemptFailed);
			m_owner.stage.addEventListener("Meriam_04_Fail_done", attemptFailed);
			
			/* set actor */
			setActor( m_foreground.Harry_Masuk );
			
			/* show gui */
			showGUI();
			
			ParticleManager.getInstance().add(CEmitterCaveDust, 0, 0);
			ParticleManager.getInstance().add(CEmitterDessertDust, 0, 0);
			
			setCountdown(80);		// set countdown
			
			if( !m_bgm )
				m_bgm = SoundManager.getInstance().playMusic("Music_FastTalkin", 1000);
		}
		
		/* SIMULATION STARTING POINT */
		override protected function startSimulation(event:TimerEvent):void 
		{	
			super.startSimulation(event);
			m_foreground.scorpion.visible = false;
			
			/* first check item on slot 1 */
			
			if ( checkSlotItem(0) == 26 )										// FLAME?		(SUCCESS)
			{	
				/* set actor */
				setActor( m_foreground.Harry_Flame_Success, 500 );
			}
			else if ( checkSlotItem(0) == 7 )									// MERIAM?		(FAIL)
			{	
				/* set actor */
				setActor( m_foreground.Harry_Meriam_01_Fail );	
			}
			else if ( checkSlotItem(0) == 21 )									// CERMIN?		(FAIL)
			{	
				/* set actor */
				setActor( m_foreground.Harry_Cermin_01_Fail );
			}
			else if ( checkSlotItem(0) == 25 )									// GRANAT?		(FAIL)
			{	
				/* set actor */
				setActor( m_foreground.Harry_Granat_01_Fail );
			}
			
			hideSlotItem(0);				
		}
		
		/* SIMULATION COMPLETE */
		override protected function simulationComplete():void 
		{
			super.simulationComplete();
			
			/* I SEE DEAD STICK ACHIEVEMENT */
			if ( !GlobalData.achievementFinallyHome )
			{
				GlobalData.achievementFinallyHome = true;
				achievementMessage(	GlobalData.achievementString["finallyHome"][0],
									GlobalData.achievementString["finallyHome"][1] );
									
				unlockNewgroundsMedal("Finaly Home");
			}
			
			
			if ( m_bgm )	m_bgm.stop();
			m_bgm = null;
			
			GameStateManager.getInstance().setState( GameState_EndingMovie.getInstance() );
		}
		
		/* EVENT ANIMASI */
		private function flameSuccess(event:Event):void
		{
			m_owner.stage.removeEventListener("Flame_Success_done", flameSuccess);
			
			m_foreground.alien_01.visible = false;
			
			/* now check item on slot 2 */
			
			if ( checkSlotItem(1) == 7 )										// MERIAM?		(SUCCESS)
			{	
				/* set actor */
				setActor( m_foreground.Harry_Meriam_Success, 1100 );	
			}
			else if ( checkSlotItem(1) == 25 )									// GRANAT?		(SUCCESS)
			{	
				/* set actor */
				setActor( m_foreground.Harry_Granat_01_Success, 1100 );
			}
			else if ( checkSlotItem(1) == 21 )									// CERMIN?		(SUCCESS)
			{	
				/* set actor */
				setActor( m_foreground.Harry_Cermin_02_Success, 1100 );
			}
			
			hideSlotItem(1);	
		}
		
		private function granat01Success(event:Event):void
		{
			m_owner.stage.removeEventListener("Granat_01_Success_done", granat01Success);
			m_foreground.alien_02.visible = false;
			
			/* now check item on slot 3 (without grenade all fail) */
			
			if ( checkSlotItem(2) == 7 )										// MERIAM?		(FAIL)
			{	
				/* set actor */
				setActor( m_foreground.Harry_Meriam_03_Fail );	
			}
			else if ( checkSlotItem(2) == 21 )									// CERMIN?		(FAIL)
			{	
				/* set actor */
				setActor( m_foreground.Harry_Cermin_03_Fail );
			}
			
			hideSlotItem(2);
		}
		
		private function cermin02Success(event:Event):void
		{
			m_owner.stage.removeEventListener( "Cermin_02_Success_done", cermin02Success );
			m_foreground.alien_02.visible = false;
			
			if ( checkSlotItem(2) == 7 )										// MERIAM?		(FAIL)
			{	
				/* set actor */
				setActor( m_foreground.Harry_Meriam_03_Fail );	
			}
			else if ( checkSlotItem(2) == 25 )									// GRANAT?		(SUCCESS)
			{	
				/* set actor */
				setActor( m_foreground.Harry_Granat_02_Success, 1750 );
			}
			
			hideSlotItem(2);
		}
		
		private function meriamSuccess(event:Event):void
		{
			m_owner.stage.removeEventListener("Meriam_Success_done", meriamSuccess);
			m_foreground.alien_02.visible = false;
			
			/* now check item on slot 3 (with grenade) */
			if ( checkSlotItem(2) == 25 )									// GRANAT?		(SUCCESS)
			{	
				/* set actor */
				setActor( m_foreground.Harry_Granat_02_Success, 1700 );
				
			}
			else if ( checkSlotItem(2) == 21 )								// CERMIN?		(FAIL)
			{	
				/* set actor */
				setActor( m_foreground.Harry_Cermin_03_Fail );
			}
			
			hideSlotItem(2);
		}
		
		private function granat02Success(event:Event):void
		{
			m_owner.stage.removeEventListener("Granat_02_Success_done", granat02Success);
			
			/* now check item on slot 4 */
			if ( checkSlotItem(3) == 21 )									// CERMIN?		(SUCCESS)
			{	
				/* set actor */
				setActor( m_foreground.Harry_Cermin_Success, 2200 );
				m_foreground.ghost.visible = false;
			}
			else if ( checkSlotItem(3) == 7 )								// MERIAM?		(FAIL)
			{	
				/* set actor */
				setActor( m_foreground.Harry_Meriam_04_Fail );
				m_foreground.ghost.visible = false;
			}
			hideSlotItem(3);
		}
		
		private function cerminSuccess(event:Event):void
		{			
			m_owner.stage.removeEventListener("Cermin_Success_done", cerminSuccess);
			simulationComplete();
		}
		
		private function attemptFailed(event:Event):void
		{
			m_owner.stage.removeEventListener("Cermin_01_Fail_done", attemptFailed);
			m_owner.stage.removeEventListener("Granat_01_Fail_done", attemptFailed);
			m_owner.stage.removeEventListener("Meriam_01_Fail_done", attemptFailed);
			m_owner.stage.removeEventListener("Cermin_02_Fail_done", attemptFailed);
			m_owner.stage.removeEventListener("Cermin_03_Fail_done", attemptFailed);
			m_owner.stage.removeEventListener("Meriam_03_Fail_done", attemptFailed);
			m_owner.stage.removeEventListener("Meriam_04_Fail_done", attemptFailed);
			
			gameOver(true);
		}
		
		/* ============================
		 * 			SINGLETON
		 * ============================
		 */
		
		static public function getInstance(): GameState_Level_10
		{
			if( m_instance == null ){
				m_instance = new GameState_Level_10( new SingletonLock() );
			}
			return m_instance;
		}
	}
}

class SingletonLock{}