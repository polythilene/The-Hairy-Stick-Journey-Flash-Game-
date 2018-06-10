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
	public class GameState_Level_07 extends CStickgerinLevel
	{
		static private var m_instance:GameState_Level_07;
		
		public function GameState_Level_07(lock:SingletonLock) {}
		
		
		override protected function prepareScene():void 
		{
			/* setup layer */
			m_sky = new Sky_Level_07;
			m_sky.x = 0;
			m_sky.y = 0;
						
			m_background = new Background_Level_07;
			m_background.x = m_background.y = 0; 
			m_bgMaxWidth = 1000;
			
			m_foreground = new Foreground_Level_07;
			m_foreground.x = m_foreground.y = 0 ;
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
			m_currentLevel = 7;
			setLevelAccess(m_currentLevel);
			
			super.enter();
			
			/* hide actors */
			prepareActor( m_foreground.masuk_2_3 );
			prepareActor( m_foreground.ob1_rakit_fail );
			prepareActor( m_foreground.ob1_ffood_fail );
			prepareActor( m_foreground.ob1_bunga_fail );
			prepareActor( m_foreground.ob1_madu_fail );
			prepareActor( m_foreground.ob1_kayu_success );
			prepareActor( m_foreground.ob2_rakit_fail );
			prepareActor( m_foreground.ob2_ffood_fail );
			prepareActor( m_foreground.ob2_madu_fail );
			prepareActor( m_foreground.ob2_bunga_success );
			prepareActor( m_foreground.ob3_rakit_success );
			prepareActor( m_foreground.ob3_madu_fail );
			prepareActor( m_foreground.ob3_fishfood_fail );
			
			/* set inventory */
			MovieClip(m_itemContainer[0]).gotoAndStop(15);		// slot 1 = perangkap
			MovieClip(m_itemContainer[1]).gotoAndStop(19);		// slot 2 = kampak
			MovieClip(m_itemContainer[2]).gotoAndStop(16);		// slot 3 = tangga
			MovieClip(m_itemContainer[3]).gotoAndStop(18);		// slot 4 = TNT
			MovieClip(m_itemContainer[4]).gotoAndStop(17);		// slot 4 = TNT

			/* listen to event */
			m_owner.stage.addEventListener("enter_stage_done", masuk_2_3 );
			m_owner.stage.addEventListener("ob1_kayu_success_done", ob1_kayu_success_done );
			m_owner.stage.addEventListener("ob2_bunga_success_done", ob2_bunga_success_done );
			m_owner.stage.addEventListener("ob3_rakit_success_done", ob3_rakit_success_done );
			
			m_owner.stage.addEventListener("ob1_rakit_fail_done", attemptFailed );
			m_owner.stage.addEventListener("ob1_ffood_fail_done", attemptFailed);
			m_owner.stage.addEventListener("ob1_bunga_fail_done", attemptFailed );
			m_owner.stage.addEventListener("ob1_madu_fail_done", attemptFailed );
			m_owner.stage.addEventListener("ob2_rakit_fail_done", attemptFailed );
			m_owner.stage.addEventListener("ob2_ffood_fail_done", attemptFailed );
			m_owner.stage.addEventListener("ob2_madu_fail_done", attemptFailed );
			m_owner.stage.addEventListener("ob3_madu_fail_done", attemptFailed);
			m_owner.stage.addEventListener("ob3_fishfood_fail_done", attemptFailed);
			
			/* set actor */
			setActor(m_foreground.masuk_2_3);
			
			/* show gui */
			showGUI();
			
			ParticleManager.getInstance().add(CEmitterFireFlies, 0, 0);
			
			setCountdown(60);		// set countdown
			
			if( !m_bgm )
				m_bgm = SoundManager.getInstance().playMusic("Music_DancesAndDames", 1000);
		}
		
		/* SIMULATION STARTING POINT */
		override protected function startSimulation(event:TimerEvent):void 
		{	
			super.startSimulation(event);	
			
			/* first check item on slot 1 */
			
			if ( checkSlotItem(0) == 15 )										// RAKIT?		(FAIL)
			{	
				/* set actor */
				setActor(m_foreground.ob1_rakit_fail);
				m_foreground.buaya_idle.visible = false;
			}
			else if ( checkSlotItem(0) == 16 )									// CACING?		  (FAIL)
			{
				/* set actor */
				setActor(m_foreground.ob1_ffood_fail);
				m_foreground.buaya_idle.visible = false;
			}
			else if ( checkSlotItem(0) == 17 )									// BUNGA?		(FAIL)
			{
				/* set actor */
				setActor(m_foreground.ob1_bunga_fail);		
			}
			else if ( checkSlotItem(0) == 18 ){
				/* set actor */
				setActor(m_foreground.ob1_madu_fail);								// MADU  (FAIL)
			}
			else if ( checkSlotItem(0) == 19 ){
				/* set actor */
				m_foreground.buaya_idle.visible = false;
				setActor(m_foreground.ob1_kayu_success);							// KAYU  (SUCCESS)
			}

			hideSlotItem(0);				
		}
		
		/* SIMULATION COMPLETE */
		override protected function simulationComplete():void 
		{
			super.simulationComplete();
			GameStateManager.getInstance().setState( GameState_Level_08.getInstance() );
		}
		
		/* EVENT ANIMASI */
		private function ob1_kayu_success_done(event:Event):void 
		{
			m_owner.stage.removeEventListener("ob1_kayu_success_done", ob1_kayu_success_done)
			
			/* check slot 2 */
			
			if ( checkSlotItem(1) == 15 )									// RAKIT?		(FAIL)
			{
				/* set actor */
				setActor(m_foreground.ob2_rakit_fail);
			}
			else if ( checkSlotItem(1) == 16 )								// FISH FOOD?		(FAIL)
			{
				/* set actor */
				setActor(m_foreground.ob2_ffood_fail);			
			}
			else if ( checkSlotItem(1) == 17) 								// BUNGA  (SUCCESS)
			{
				/* set actor */
				m_foreground.kudanil_idle.visible = false;
				setActor(m_foreground.ob2_bunga_success)
			}
			else if ( checkSlotItem(1) == 18) 								// MADU  (FAIL)
			{
				/* set actor */
				setActor(m_foreground.ob2_madu_fail)
			}
			
			hideSlotItem(1);
		}
		
		private function masuk_2_3(event:Event):void 
		{
			/*remove listener*/
			m_owner.stage.removeEventListener("enter_stage_done", masuk_2_3);
			
			/*game started*/
			m_cutScene = false;
		}
		
		private function ob2_bunga_success_done(event:Event):void
		{
			m_owner.stage.removeEventListener("ob2_bunga_success_done", ob2_bunga_success_done );
			
			/* check slot 3 */
			
			if ( checkSlotItem(2) == 15 )									// RAKIT?		(SUCCESS)
			{
				/* set actor */
				setActor(m_foreground.ob3_rakit_success);
			}
			else if ( checkSlotItem(2) == 18 )								// MADU?		(FAIL)
			{
				/* set actor */
				setActor(m_foreground.ob3_madu_fail);			
			}
			else if ( checkSlotItem(2) == 16 )								// CACING?		(FAIL)
			{
				/* set actor */
				setActor( m_foreground.ob3_fishfood_fail );
			}
			
			hideSlotItem(2);
		}

		private function ob3_rakit_success_done(event:Event):void
		{
			m_owner.stage.removeEventListener("ob3_rakit_success_done", ob3_rakit_success_done );
			
			simulationComplete();
		}
		
		private function attemptFailed(event:Event):void
		{
			m_owner.stage.removeEventListener("ob1_rakit_fail_done", attemptFailed );
			m_owner.stage.removeEventListener("ob1_ffood_fail_done", attemptFailed);
			m_owner.stage.removeEventListener("ob1_bunga_fail_done", attemptFailed );
			m_owner.stage.removeEventListener("ob1_madu_fail_done", attemptFailed );
			m_owner.stage.removeEventListener("ob2_rakit_fail_done", attemptFailed );
			m_owner.stage.removeEventListener("ob2_ffood_fail_done", attemptFailed );
			m_owner.stage.removeEventListener("ob2_madu_fail_done", attemptFailed );
			m_owner.stage.removeEventListener("ob3_madu_fail_done", attemptFailed);
			m_owner.stage.removeEventListener("ob3_fishfood_fail_done", attemptFailed);
			
			gameOver( (event.type.toString() != "ob1_bunga_fail_done" && 
					   event.type.toString() != "ob1_madu_fail_done") );
					   
			/* STICK VERSUS WILD */
			if ( !GlobalData.achievementStickVersusWild )
			{
				if( event.type.toString() == "ob1_ffood_fail_done" || 
					event.type.toString() == "ob1_rakit_fail_done" )
					GlobalData.eatenByCrocodile = true;
					
				if( event.type.toString() == "ob2_rakit_fail_done" ||
				    event.type.toString() == "ob2_ffood_fail_done" )
					GlobalData.eatenByPiranha = true;
				
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
		
		static public function getInstance(): GameState_Level_07
		{
			if( m_instance == null ){
				m_instance = new GameState_Level_07( new SingletonLock() );
			}
			return m_instance;
		}
	}
}

class SingletonLock{}