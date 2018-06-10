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
	public class GameState_Level_04 extends CStickgerinLevel
	{
		static private var m_instance:GameState_Level_04;
		
		public function GameState_Level_04(lock:SingletonLock) { }
		
		
		override protected function prepareScene():void 
		{
			/* setup layer */
			m_sky = new Sky_Level_04;
			m_sky.x = 0;
			m_sky.y = 0;
						
			m_background = new Background_Level_04;
			m_background.x = m_background.y = 0;
			m_bgMaxWidth = 1100;
			
			m_foreground = new Foreground_Level_04;
			m_foreground.x = m_foreground.y = 0;
			m_fgMaxWidth = 1200;
			
			/* link slot to clip */
			m_itemSlots[0] = m_foreground.slot_01;
			m_itemSlots[1] = m_foreground.slot_02;
			//m_itemSlots[2] = m_foreground.slot_03;
			
			super.prepareScene();
		}
		
		override public function enter():void 
		{
			/* set level id */
			m_currentLevel = 4;
			setLevelAccess(m_currentLevel);
			
			super.enter();
			
			/* hide actors */
			prepareActor( m_foreground.harry_meledak );
			prepareActor( m_foreground.harry_nabrak );
			prepareActor( m_foreground.harry_ketiban_batu );
			prepareActor( m_foreground.harry_terbang );
			prepareActor( m_foreground.harry_lewati_batu );
			
			/* set inventory */
			MovieClip(m_itemContainer[0]).gotoAndStop(8);		// slot 1 = tangga
			MovieClip(m_itemContainer[1]).gotoAndStop(7);		// slot 2 = pengungkit
			MovieClip(m_itemContainer[2]).gotoAndStop(9);		// slot 3 = kampak
			
			/* listen to event */
			m_owner.stage.addEventListener("balloon_success_end", balloonSuccessEnd);
			m_owner.stage.addEventListener("cannon_success_end", cannonSuccessEnd);
			
			m_owner.stage.addEventListener("cannon_fail_end", attemptFailed);
			m_owner.stage.addEventListener("TNT_fail_end", attemptFailed);
			m_owner.stage.addEventListener("TNT2_fail_end", attemptFailed);
			
			/* show GUI */
			m_cutScene = false;
			setCountdown(60);
			showGUI();
			
			/* set actor */
			setActor(m_foreground.harry_masuk);
			
			/* set environment particle */
			ParticleManager.getInstance().add(CEmitterForestMist, 0, 0);
			ParticleManager.getInstance().add(CEmitterFallingLeaves, 0, 0);
			
			if( !m_bgm )
				m_bgm = SoundManager.getInstance().playMusic("Music_FastTalkin", 1000);
		}
		
		/* SIMULATION STARTING POINT */
		override protected function startSimulation(event:TimerEvent):void 
		{	
			super.startSimulation(event);
			
			/* first check item on slot 1 */
			
			if ( checkSlotItem(0) == 7 )									// CANNON?		(FAIL)
			{
				/* set actor */
				setActor(m_foreground.harry_nabrak);
			}
			else if ( checkSlotItem(0) == 8 )								// BALON?		(SUCCESS)
			{
				/* set actor */
				setActor(m_foreground.harry_terbang);
			}
			else if ( checkSlotItem(0) == 9 )								// TNT?		(FAIL)
			{
				/* set actor */
				setActor(m_foreground.harry_ketiban_batu);
				m_foreground.obelisk_idle.visible = false;
			}
			
			hideSlotItem(0);				
		}
		
		override protected function simulationComplete():void 
		{
			super.simulationComplete();
			
			if( m_bgm )
				m_bgm.stop();
			
			GameStateManager.getInstance().setState( GameState_Level_05.getInstance() );
		}
		
		/* EVENT ANIMASI */
		
		private function balloonSuccessEnd(event:Event):void
		{
			m_owner.stage.removeEventListener("balloon_success_end", balloonSuccessEnd);
			//checking slot 3
			if ( checkSlotItem(1) == 7 )									// CANNON?		(SUCCESS)
			{
				/* set actor */
				setActor(m_foreground.harry_lewati_batu);
			}
			else if ( checkSlotItem(1) == 9 )								// TNT?		(FAIL)
			{
				/* set actor */
				setActor(m_foreground.harry_meledak);
			}
			hideSlotItem(1);
		}
		
		private function cannonSuccessEnd(event:Event):void	
		{
			m_owner.stage.removeEventListener("cannon_success_end", cannonSuccessEnd);
			simulationComplete();
		}
		
		private function attemptFailed(event:Event):void	
		{
			m_owner.stage.removeEventListener("cannon_fail_end", attemptFailed);
			m_owner.stage.removeEventListener("TNT_fail_end", attemptFailed);
			m_owner.stage.removeEventListener("TNT2_fail_end", attemptFailed);
			
			
			gameOver(true);
			
			/* TNT VICTIM */
			if( event.type.toString() == "TNT_fail_end" ||
				event.type.toString() == "TNT2_fail_end" )
			{
				trace("Trying to unlock TNT Victim");
				
				if ( !GlobalData.achievementTNTVictim )
				{
					GlobalData.achievementTNTVictimCounter++;
					trace("Counter:", GlobalData.achievementTNTVictimCounter);
					
					if( GlobalData.achievementTNTVictimCounter >= 3 )
					{
						trace("TNT Victim unlocked");
						GlobalData.achievementTNTVictim = true;
						achievementMessage(	GlobalData.achievementString["tntVictim"][0],
											GlobalData.achievementString["tntVictim"][1] );
						
						unlockNewgroundsMedal("TNT Victim");
					}
				}
			}
		}

		/* ============================
		 * 			SINGLETON
		 * ============================
		 */
		
		static public function getInstance(): GameState_Level_04
		{
			if( m_instance == null ){
				m_instance = new GameState_Level_04( new SingletonLock() );
			}
			return m_instance;
		}
	}
}

class SingletonLock{}