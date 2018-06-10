package  
{
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.events.MouseEvent;
	
	import gs.TweenMax;
		
	/**
	 * ...
	 * @author Wiwit
	 */
	public class GameState_OpeningMovie extends CGameState
	{
		static private var m_instance:GameState_OpeningMovie;
		
		public function GameState_OpeningMovie(lock:SingletonLock) {}
		
		/* objects */
		private var mc_OpeningMovie:ScreenOpeningMovie;
		private var m_music:CSoundObject;
		private var m_delayCounter:Timer;
		
		override public function initialize(owner:DisplayObjectContainer):void 
		{
			super.initialize(owner);
		}
		
		override public function enter():void 
		{
			super.enter();
			
			mc_OpeningMovie = new ScreenOpeningMovie();
			m_owner.addChild(mc_OpeningMovie);
			
			mc_OpeningMovie.x = 400.6;
			mc_OpeningMovie.y = 224.4;

			mc_OpeningMovie.skipButton.buttonMode = mc_OpeningMovie.useHandCursor = true;
			mc_OpeningMovie.skipButton.addEventListener(MouseEvent.CLICK, buttonClicked);
			mc_OpeningMovie.skipButton.addEventListener(MouseEvent.MOUSE_OVER, buttonHover);
			mc_OpeningMovie.skipButton.addEventListener(MouseEvent.MOUSE_OUT, buttonOut);
			
			/* play music */
			m_music = SoundManager.getInstance().playMusic("Music_HotSwing", 1000);
			
			/* listen to movie end announcer */
			m_owner.stage.addEventListener("OpeningMovie_End", movieEnd);
		}
		
		override public function exit():void 
		{
			mc_OpeningMovie.skipButton.removeEventListener(MouseEvent.CLICK, buttonClicked);
			mc_OpeningMovie.skipButton.removeEventListener(MouseEvent.MOUSE_OVER, buttonHover);
			mc_OpeningMovie.skipButton.removeEventListener(MouseEvent.MOUSE_OUT, buttonOut);
			
			m_music.stop();
			m_owner.removeChild(mc_OpeningMovie);
			mc_OpeningMovie = null;
		}
		
		protected function movieEnd(e:Event):void 
		{
			m_owner.stage.removeEventListener("OpeningMovie_End", movieEnd);
			m_music.fadeOut(5);
			
			m_delayCounter = new Timer(5500);	// delay 5.5 seconds
			m_delayCounter.addEventListener(TimerEvent.TIMER, delayComplete);
			m_delayCounter.start();
			
			
			/* MOVIE FREAK ACHIEVEMENT */
			if ( !GlobalData.achievementMovieFreak )
			{
				trace("Trying to unlock movie freak");
				GlobalData.openingMovieFinished = true;
				
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
			
			GameStateManager.getInstance().setState( GameState_Level_01.getInstance() );
		}
		
		private function buttonClicked(event:MouseEvent):void
		{
			SoundManager.getInstance().playSFX("SFX_Button03");
			TweenMax.killTweensOf(mc_OpeningMovie.skipButton);
			GameStateManager.getInstance().setState( GameState_Level_01.getInstance() );
		}
		
		private function buttonHover(event:MouseEvent):void
		{
			SoundManager.getInstance().playSFX("SFX_Button01");
			if( mc_OpeningMovie && mc_OpeningMovie.skipButton )
				TweenMax.to(mc_OpeningMovie.skipButton, 0.25, { scaleX:1.2, scaleY:1.2 } );
		}
		
		private function buttonOut(event:MouseEvent):void
		{
			if( mc_OpeningMovie && mc_OpeningMovie.skipButton )
				TweenMax.to(mc_OpeningMovie.skipButton, 0.5, { scaleX:1.0, scaleY:1.0 } );
		}
		
		/* ============================
		 * 			SINGLETON
		 * ============================
		 */
		
		static public function getInstance(): GameState_OpeningMovie
		{
			if( m_instance == null ){
				m_instance = new GameState_OpeningMovie( new SingletonLock() );
			}
			return m_instance;
		}
	}
}

class SingletonLock{}