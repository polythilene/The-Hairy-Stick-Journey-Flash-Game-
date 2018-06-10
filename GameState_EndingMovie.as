package  
{
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import gs.TweenMax;
		
	/**
	 * ...
	 * @author Wiwit
	 */
	public class GameState_EndingMovie extends CGameState
	{
		static private var m_instance:GameState_EndingMovie;
		
		public function GameState_EndingMovie(lock:SingletonLock) {}
		
		
		/* objects */
		private var mc_EndingMovie:ScreenEndingMovie;
		private var m_delayCounter:Timer;
		private var m_music:CSoundObject;	
		
		override public function enter():void 
		{
			super.enter();
			
			mc_EndingMovie = new ScreenEndingMovie();
			m_owner.addChild(mc_EndingMovie);
			
			mc_EndingMovie.x = 400.6;
			mc_EndingMovie.y = 224.4;
					
			mc_EndingMovie.skipButton.buttonMode = mc_EndingMovie.useHandCursor = true;
			mc_EndingMovie.skipButton.addEventListener(MouseEvent.CLICK, buttonClicked);
			mc_EndingMovie.skipButton.addEventListener(MouseEvent.MOUSE_OVER, buttonHover);
			mc_EndingMovie.skipButton.addEventListener(MouseEvent.MOUSE_OUT, buttonOut);
			
			/* play music */
			m_music = SoundManager.getInstance().playMusic("Music_HotSwing", 1000);
			
			/* listen to movie end announcer */
			m_owner.stage.addEventListener("EndingMovie_End", movieEnd);
		}
		
		override public function exit():void 
		{
			mc_EndingMovie.skipButton.addEventListener(MouseEvent.CLICK, buttonClicked);
			mc_EndingMovie.skipButton.addEventListener(MouseEvent.MOUSE_OVER, buttonHover);
			mc_EndingMovie.skipButton.addEventListener(MouseEvent.MOUSE_OUT, buttonOut);
			
			m_owner.removeChild(mc_EndingMovie);
			mc_EndingMovie = null;
			
			m_music.stop();
		}
		
		protected function movieEnd(e:Event):void 
		{
			m_owner.stage.removeEventListener("EndingMovie_End", movieEnd);
			m_music.fadeOut(5);
			
			m_delayCounter = new Timer(5500);	// delay 5.5 seconds
			m_delayCounter.addEventListener(TimerEvent.TIMER, delayComplete);
			m_delayCounter.start();
			
			/* MOVIE FREAK ACHIEVEMENT */
			if ( !GlobalData.achievementMovieFreak )
			{
				GlobalData.endingMovieFinished = true;
				
				trace("Trying to unlock movie freak");
				
				if( GlobalData.openingMovieFinished == true && 
					GlobalData.endingMovieFinished == true )
				{
					trace("Movie freak unlocked");
					GlobalData.achievementMovieFreak = true;
					achievementMessage(	GlobalData.achievementString["movieFreak"][0],
										GlobalData.achievementString["movieFreak"][1] );
										
					unlockNewgroundsMedal("Movie Freak");
				}
			}
		}
		
		protected function delayComplete(e:TimerEvent=null):void
		{
			m_delayCounter.removeEventListener(TimerEvent.TIMER, delayComplete);
			m_music.stop();
			
			GameStateManager.getInstance().setState( GameState_BGLogo.getInstance() );
		}
		
		private function buttonClicked(event:MouseEvent):void
		{
			SoundManager.getInstance().playSFX("SFX_Button03");
			TweenMax.killTweensOf(mc_EndingMovie.skipButton);
			GameStateManager.getInstance().setState( GameState_BGLogo.getInstance() );
		}
		
		private function buttonHover(event:MouseEvent):void
		{
			SoundManager.getInstance().playSFX("SFX_Button01");
			if( mc_EndingMovie && mc_EndingMovie.skipButton )
				TweenMax.to(mc_EndingMovie.skipButton, 0.25, { scaleX:1.2, scaleY:1.2 } );
		}
		
		private function buttonOut(event:MouseEvent):void
		{
			if( mc_EndingMovie && mc_EndingMovie.skipButton )
				TweenMax.to(mc_EndingMovie.skipButton, 0.5, { scaleX:1.0, scaleY:1.0 } );
		}
		
		/* ============================
		 * 			SINGLETON
		 * ============================
		 */
		
		static public function getInstance(): GameState_EndingMovie
		{
			if( m_instance == null ){
				m_instance = new GameState_EndingMovie( new SingletonLock() );
			}
			return m_instance;
		}
	}
}

class SingletonLock{}