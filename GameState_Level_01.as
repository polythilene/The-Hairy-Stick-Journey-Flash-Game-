package  
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	
	import gs.TweenMax;
		
	/**
	 * ...
	 * @author Wiwit
	 */
	public class GameState_Level_01 extends CStickgerinLevel
	{
		static private var m_instance:GameState_Level_01;
		
		
		private var m_showCreditStarted:Boolean;
		private var m_tutorialScreen:TutorialClip;
		
		public function GameState_Level_01(lock:SingletonLock) { }
		
		override public function initialize(owner:DisplayObjectContainer):void 
		{
			super.initialize(owner);
		}
		
		override protected function prepareScene():void 
		{
			/* setup layer */
			m_sky = new Sky_Level_01;
			m_sky.x = HALF_WIDTH;
			m_sky.y = HALF_HEIGHT;
						
			m_background = new Background_Level_01;
			m_background.x = m_background.y = 0;
			m_bgMaxWidth = 1035;
			
			m_foreground = new Foreground_Level_01;
			m_foreground.x = m_foreground.y = 0;
			m_fgMaxWidth = 1228;
			
			/* link slot to clip */
			m_itemSlots[0] = m_foreground.slot_01;
			m_itemSlots[1] = m_foreground.slot_02;
			
			super.prepareScene();
		}
		
		override public function enter():void 
		{
			/* reset global var */
			GlobalData.careerScore = 0;
						
			/* set level parameters */
			m_currentLevel = 1;
			setLevelAccess(m_currentLevel);
			m_showCreditStarted = false;
			
			super.enter();
			
			/* hide animation */
			prepareActor( m_foreground.harry_jatuh_dari_tangga );
			prepareActor( m_foreground.harry_lempar_tali );
			prepareActor( m_foreground.harry_naik_tangga );

			m_foreground.pintu_terbuka.visible = false;
			
			/* set inventory */
			MovieClip(m_itemContainer[0]).gotoAndStop(2);			// slot 1 = tali kait
			MovieClip(m_itemContainer[1]).gotoAndStop(3);			// slot 2 = tangga
			
			/* listen to event */
			m_owner.stage.addEventListener("Falling_Done", animasiJatuhEnd);
			m_owner.stage.addEventListener("Jumping_Done", animasiJumpingEnd);
			m_owner.stage.addEventListener("StairFall_Done", animasiStairFallEnd);
			m_owner.stage.addEventListener("StairClimb_Done", animasiStairClimbEnd);
			
			/* start cut scene, harry fall down from the sky */
			m_cutScene = true;
			
			/* set actor */
			setActor(m_foreground.harry_jatuh_dari_langit);
			
			/* set environment particle */
			ParticleManager.getInstance().add(CEmitterForestMist, 0, 0);
			ParticleManager.getInstance().add(CEmitterFallingLeaves, 0, 0);
			
			/* set ingame credits */
			InGameCredits.getInstance().attach(m_owner); 
			
			if( GlobalData.showBubbleBoxLogo )
				InGameCredits.getInstance().addCredit("Sponsored By", "BubbleBox");
			
			if ( GlobalData.showAndkonLogo )	
				InGameCredits.getInstance().addCredit("", "Andkon Arcade");
				
			if( GlobalData.showBelugerinLogo )
				InGameCredits.getInstance().addCredit("a Game By", "Belugerin Studios");
				
			InGameCredits.getInstance().addCredit("Game Designer", "Bayu Putra");
			InGameCredits.getInstance().addCredit("Game Designer", "Aditya Sumantri");
			InGameCredits.getInstance().addCredit("Executive Producer", "Abdul Kahar");
			InGameCredits.getInstance().addCredit("Executive Producer", "Arief Raditya");
			
			
			/* tutorial */
			m_tutorialScreen = new TutorialClip();
			m_tutorialScreen.useHandCursor = m_tutorialScreen.buttonMode = true;
			
			GlobalData.showTutorial = (GlobalData.showYouYouWinLogo) ? false : true;
			
			/* play music */
			if( m_bgm )	
				m_bgm.stop();
				
			m_bgm = SoundManager.getInstance().playMusic("Music_FastTalkin", 1000);
		}
		
		override public function update(elapsedTime:int):void 
		{
			super.update(elapsedTime);
			
			if( m_showCreditStarted )
				InGameCredits.getInstance().update(elapsedTime);
		}
		
		override public function exit():void 
		{
			GlobalData.showTutorial = false;
			
			InGameCredits.getInstance().clear();
			InGameCredits.getInstance().detach(); 
			super.exit();
		}
		
		/* SIMULATION STARTING POINT */
		
		
		override protected function startSimulation(event:TimerEvent):void 
		{	
			super.startSimulation(event);
			
			m_foreground.pintu_terbuka.visible = true;
			
			/* first check item on slot 1 */
			
			if ( checkSlotItem(0) == 2 )									// TALI?		(SUCCESS)
			{
				/* set actor */
				setActor(m_foreground.harry_lempar_tali);
			}
			else if ( checkSlotItem(0) == 3 )								// TANGGA?		(FAIL)
			{
				/* set actor */
				setActor(m_foreground.harry_jatuh_dari_tangga);
			}
			hideSlotItem(0);												// hide item in first slot, whatever that is
		}
		
		/* SIMULATION COMPLETE */
		override protected function simulationComplete():void 
		{
			super.simulationComplete();
			GameStateManager.getInstance().setState( GameState_Level_02.getInstance() );
		}
		
		/* EVENT ANIMASI */
		
		private function animasiJatuhEnd(event:Event):void
		{
			m_owner.stage.removeEventListener("Falling_Done", animasiJatuhEnd);
			showGUI();
			
			/* show tutorial */
			if ( GlobalData.showTutorial )
			{
				showTutorial();
			}
			else
			{
				m_cutScene = false;
				setCountdown(60);				// set countdown
				m_showCreditStarted = true;
			}
		}
		
		private function showTutorial():void
		{
			addChild(m_tutorialScreen);
			m_tutorialScreen.gotoAndStop(1);
			m_GUI.mouseChildren = false;
			m_tutorialScreen.alpha = 0;
			TweenMax.to( m_tutorialScreen, 3, { alpha:1 } );
			m_owner.addEventListener(MouseEvent.CLICK, tutorialContinue);
		}
		
		private function closeTutorial():void
		{
			removeChild(m_tutorialScreen);
			m_GUI.mouseChildren = true;
			m_owner.removeEventListener(MouseEvent.CLICK, tutorialContinue);
			
			m_cutScene = false;
			setCountdown(60);		// set countdown
			m_showCreditStarted = true;
		}
		
		private function tutorialContinue(event:MouseEvent):void
		{
			if ( m_tutorialScreen.currentFrame < m_tutorialScreen.totalFrames )
			{
				m_tutorialScreen.gotoAndStop( m_tutorialScreen.currentFrame + 1 );
			}
			else closeTutorial();
		}
		
		private function animasiJumpingEnd(event:Event):void
		{
			m_owner.stage.removeEventListener("Jumping_Done", animasiJumpingEnd);
		
			hideSlotItem(1);				// after use, hide item in second slot
			
			/* set actor */
			setActor(m_foreground.harry_naik_tangga);
		}
		
		private function animasiStairFallEnd(event:Event):void
		{
			m_owner.stage.removeEventListener("StairFall_Done", animasiStairFallEnd);
			gameOver(true);
		}
			
		private function animasiStairClimbEnd(event:Event):void	
		{
			m_owner.stage.removeEventListener("StairClimb_Done", animasiStairClimbEnd);
			simulationComplete();
		}
		
		/* ============================
		 * 			SINGLETON
		 * ============================
		 */
		
		static public function getInstance(): GameState_Level_01
		{
			if( m_instance == null ){
				m_instance = new GameState_Level_01( new SingletonLock() );
			}
			return m_instance;
		}
	}
}

class SingletonLock{}