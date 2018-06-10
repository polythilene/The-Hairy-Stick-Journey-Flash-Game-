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
	public class GameState_Level_08 extends CStickgerinLevel
	{
		static private var m_instance:GameState_Level_08;
		
		public function GameState_Level_08(lock:SingletonLock) {}
		
		
		override protected function prepareScene():void 
		{
			/* setup layer */
			m_sky = null;
						
			m_background = new Background_Level_08;
			m_background.x = m_background.y = 0; 
			m_bgMaxWidth = 1300;
			
			m_foreground = new Foreground_Level_08;
			m_foreground.x = m_foreground.y = 0;
			m_fgMaxWidth = 1680;
			
			/* link slot to clip */
			m_itemSlots[0] = m_foreground.slot_01;
			m_itemSlots[1] = m_foreground.slot_02;
			m_itemSlots[2] = m_foreground.slot_03;
			
			super.prepareScene();
		}
		
		override public function enter():void 
		{
			m_currentLevel = 8;
			setLevelAccess(m_currentLevel);
			
			super.enter();
			
			/* hide actors */
			prepareActor( m_foreground.harry_masuk );
			prepareActor( m_foreground.harry_cermin_success );
			prepareActor( m_foreground.harry_meriam_fail );
			prepareActor( m_foreground.harry_rakit_fail_01 );
			prepareActor( m_foreground.harry_obor_fail_01 );
			prepareActor( m_foreground.harry_meriam_success );
			prepareActor( m_foreground.harry_rakit_fail_02 );
			prepareActor( m_foreground.harry_obor_fail_02 );
			prepareActor( m_foreground.harry_rakit_success );
			prepareActor( m_foreground.harry_obor_fail_03 );
			
			/* set inventory */
			MovieClip(m_itemContainer[0]).gotoAndStop(7);		// slot 1 = meriam
			MovieClip(m_itemContainer[1]).gotoAndStop(15);		// slot 2 = rakit
			MovieClip(m_itemContainer[2]).gotoAndStop(20);		// slot 3 = obor	
			MovieClip(m_itemContainer[3]).gotoAndStop(21);		// slot 4 = cermin
			
			/* listen to event */
			
			m_owner.stage.addEventListener("cermin_success_done", cerminSuccess );
			m_owner.stage.addEventListener("meriam_success_done", meriamSuccess );
			m_owner.stage.addEventListener("rakit_success_done", rakitSuccess );
						
			m_owner.stage.addEventListener("meriam_fail_done", attemptFailed );
			m_owner.stage.addEventListener("obor_01_fail_done", attemptFailed );
			m_owner.stage.addEventListener("rakit_01_fail_done", attemptFailed );
			m_owner.stage.addEventListener("obor_02_fail_done", attemptFailed );
			m_owner.stage.addEventListener("rakit_02_fail_done", attemptFailed );
			m_owner.stage.addEventListener("obor_03_fail_done", attemptFailed );
			
			/* set actor */
			setActor( m_foreground.harry_masuk );
			
			/* show gui */
			showGUI();
			
			ParticleManager.getInstance().add(CEmitterFireFlies, 0, 0);
			ParticleManager.getInstance().add(CEmitterCaveDust, 0, 0);
			
			setCountdown(60);		// set countdown
			
			if( !m_bgm )
				m_bgm = SoundManager.getInstance().playMusic("Music_DancesAndDames", 1000);
		}
		
		/* SIMULATION STARTING POINT */
		override protected function startSimulation(event:TimerEvent):void 
		{	
			super.startSimulation(event);	
			
			/* first check item on slot 1 */
			
			if ( checkSlotItem(0) == 21 )										// CERMIN?		(SUCCESS)
			{	
				/* set actor */
				setActor( m_foreground.harry_cermin_success );
				m_foreground.buntut_kadut.visible = false;
			}
			else if ( checkSlotItem(0) == 7 )									// MERIAM?		(FAIL)
			{
				/* set actor */
				setActor( m_foreground.harry_meriam_fail );
				m_foreground.buntut_kadut.visible = false;
			}
			else if ( checkSlotItem(0) == 15 )									// RAKIT?		(FAIL)
			{
				/* set actor */
				setActor( m_foreground.harry_rakit_fail_01 );
			}
			else if ( checkSlotItem(0) == 20 )									// OBOR?		(FAIL)
			{
				/* set actor */
				setActor( m_foreground.harry_obor_fail_01 );
				m_foreground.buntut_kadut.visible = false;
			}
			
			hideSlotItem(0);				
		}
		
		/* SIMULATION COMPLETE */
		override protected function simulationComplete():void 
		{
			super.simulationComplete();
			
			if( m_bgm )	m_bgm.stop();
				
			GameStateManager.getInstance().setState( GameState_Level_09.getInstance() );
		}
		
		/* EVENT ANIMASI */
		
		private function cerminSuccess(event:Event):void
		{
			m_owner.stage.removeEventListener("cermin_success_done", cerminSuccess );
			
			/* now check slot 02 */
			
			if ( checkSlotItem(1) == 7 )										// MERIAM?		(SUCCESS)
			{
				/* set actor */
				setActor( m_foreground.harry_meriam_success, 730 );
			}
			else if ( checkSlotItem(1) == 15 )									// RAKIT?		(FAIL)
			{
				/* set actor */
				setActor( m_foreground.harry_rakit_fail_02 );
			}
			else if ( checkSlotItem(1) == 20 )									// OBOR?		(FAIL)
			{
				/* set actor */
				setActor( m_foreground.harry_obor_fail_02 );
			}
			
			hideSlotItem(1);
		}
		
		private function meriamSuccess(event:Event):void
		{
			m_owner.stage.removeEventListener("meriam_success_done", meriamSuccess );
			m_foreground.kepiting_idle.visible = false;
			
			if ( checkSlotItem(2) == 15 )										// RAKIT?		(SUCCESS)
			{
				/* set actor */
				setActor( m_foreground.harry_rakit_success, 1300 );
			}
			else if ( checkSlotItem(2) == 20 )									// OBOR?		(FAIL)
			{
				/* set actor */
				setActor( m_foreground.harry_obor_fail_03 );
			}
			
			hideSlotItem(2);
		}
		
		private function rakitSuccess(event:Event):void
		{
			m_owner.stage.removeEventListener("rakit_success_done", rakitSuccess );
			simulationComplete();
		}
		
		private function attemptFailed(event:Event):void
		{
			m_owner.stage.removeEventListener("meriam_fail_done", attemptFailed );
			m_owner.stage.removeEventListener("obor_01_fail_done", attemptFailed );
			m_owner.stage.removeEventListener("rakit_01_fail_done", attemptFailed );
			m_owner.stage.removeEventListener("obor_02_fail_done", attemptFailed );
			m_owner.stage.removeEventListener("rakit_02_fail_done", attemptFailed );
			m_owner.stage.removeEventListener("obor_03_fail_done", attemptFailed );
			
			gameOver( (event.type.toString() != "rakit_01_fail_done") );
			
			/* STICK VERSUS WILD */
			if ( !GlobalData.achievementStickVersusWild )
			{
				if( event.type.toString() == "obor_02_fail_done" || 
					event.type.toString() == "rakit_02_fail_done" ||
					event.type.toString() == "obor_03_fail_done" )
					GlobalData.eatenByCrab = true;
					
				if ( GlobalData.eatenByDinosaur && GlobalData.eatenByCrab && 
					 GlobalData.eatenByPiranha && GlobalData.eatenByCrocodile )
				{
					GlobalData.achievementStickVersusWild = true;
					achievementMessage(	GlobalData.achievementString["stickVersusWild"][0],
										GlobalData.achievementString["stickVersusWild"][1] );
										
					unlockNewgroundsMedal("Stick vs Wild");
				}
				
			}		   
		}
		
		/* ============================
		 * 			SINGLETON
		 * ============================
		 */
		
		static public function getInstance(): GameState_Level_08
		{
			if( m_instance == null ){
				m_instance = new GameState_Level_08( new SingletonLock() );
			}
			return m_instance;
		}
	}
}

class SingletonLock{}