package  
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	
	import gs.TweenMax;
	import com.newgrounds.Medal;
		
	/**
	 * ...
	 * @author Wiwit
	 */
	public class GameState_Level_06 extends CStickgerinLevel
	{
		static private var m_instance:GameState_Level_06;
		
		public function GameState_Level_06(lock:SingletonLock) {}
		
		
		override protected function prepareScene():void 
		{
			/* setup layer */
			m_sky = new Sky_Level_06;
			m_sky.x = 0;
			m_sky.y = 0;
						
			m_background = new Background_Level_06;
			m_background.x = m_background.y = 0; 
			m_bgMaxWidth = 1000;
			
			m_foreground = new Foreground_Level_06;
			m_foreground.x = m_foreground.y = 0;
			m_fgMaxWidth = 1400;
			
			/* link slot to clip */
			m_itemSlots[0] = m_foreground.slot_01;
			m_itemSlots[1] = m_foreground.slot_02;
			m_itemSlots[2] = m_foreground.slot_03;
			m_itemSlots[3] = m_foreground.slot_04;

			super.prepareScene();
		}
		
		override public function enter():void 
		{
			/* set level parameters */
			m_currentLevel = 6;
			setLevelAccess(m_currentLevel);
			
			super.enter();
			
			/* hide actors */
			prepareActor( m_foreground.enter_stage);
			prepareActor( m_foreground.tongkat_1_fail );
			prepareActor( m_foreground.pisang_1_fail  );
			prepareActor( m_foreground.tnt_1_fail  );
			prepareActor( m_foreground.meat_1_fail  );
			prepareActor( m_foreground.topeng_1_success  );
			prepareActor( m_foreground.tongkat_2_fail  );
			prepareActor( m_foreground.pisang_2_fail  );
			prepareActor( m_foreground.meat_2_fail  );
			prepareActor( m_foreground.tnt_2_success  );
			prepareActor( m_foreground.tongkat_3_fail  );
			prepareActor( m_foreground.pisang_3_fail  );
			prepareActor( m_foreground.meat_3_success  );
			prepareActor( m_foreground.tnt_3_fail  );
			prepareActor( m_foreground.tongkat_4_success  );
			prepareActor( m_foreground.pisang_4_fail  );
			prepareActor( m_foreground.tnt_4_fail  );
			
			/* set inventory */
			MovieClip(m_itemContainer[0]).gotoAndStop(14);		// slot 1 = perangkap
			MovieClip(m_itemContainer[1]).gotoAndStop(9);		// slot 2 = kampak
			MovieClip(m_itemContainer[2]).gotoAndStop(11);		// slot 3 = tangga
			MovieClip(m_itemContainer[3]).gotoAndStop(13);		// slot 4 = TNT
			MovieClip(m_itemContainer[4]).gotoAndStop(12);		// slot 4 = TNT

			/* listen to event */
			m_owner.stage.addEventListener("enter_stage_done", enterStageDone );
			m_owner.stage.addEventListener("topeng_1_success_done", topeng1_success_done );
			m_owner.stage.addEventListener("tnt_2_success_done", tnt2_success_done );
			m_owner.stage.addEventListener("meat_3_success_done", meat3_success_done );
			m_owner.stage.addEventListener("tongkat_4_success_done", tongkat4_success_done );
			
			m_owner.stage.addEventListener("tongkat_1_fail_done", attemptFailed);
			m_owner.stage.addEventListener("meat_1_fail_done", attemptFailed);
			m_owner.stage.addEventListener("tnt_1_fail_done", attemptFailed);
			m_owner.stage.addEventListener("pisang_1_fail_done", attemptFailed);
			m_owner.stage.addEventListener("tongkat_2_fail_done", attemptFailed);
			m_owner.stage.addEventListener("pisang_2_fail_done", attemptFailed);
			m_owner.stage.addEventListener("meat_2_fail_done", attemptFailed);
			m_owner.stage.addEventListener("tongkat_3_fail_done", attemptFailed);
			m_owner.stage.addEventListener("pisang_3_fail_done", attemptFailed);
			m_owner.stage.addEventListener("tnt_3_fail_done", attemptFailed);
			m_owner.stage.addEventListener("tnt_4_fail_done", attemptFailed);
			m_owner.stage.addEventListener("pisang_4_fail_done", attemptFailed);
			
			/* set actor */
			setActor(m_foreground.enter_stage);
			
			/* show gui */
			showGUI();
			
			ParticleManager.getInstance().add(CEmitterForestMist, 0, 0);
			ParticleManager.getInstance().add(CEmitterFallingLeaves, 0, 0);
			
			setCountdown(60);		// set countdown
			
			if( !m_bgm )
				m_bgm = SoundManager.getInstance().playMusic("Music_DancesAndDames", 1000);
		}
		
		/* SIMULATION STARTING POINT */
		override protected function startSimulation(event:TimerEvent):void 
		{	
			super.startSimulation(event);
			
			/* first check item on slot 1 */
			
			if ( checkSlotItem(0) == 11 )									// TOPENG?		(SUCCESS)
			{
				/* set actor */
				m_foreground.batu_idle.visible = false;
				setActor(m_foreground.topeng_1_success);
			}
			else if ( checkSlotItem(0) == 9 )								// TNT?		  (FAIL)
			{
				/* set actor */
				setActor(m_foreground.tnt_1_fail);
				m_foreground.batu_idle.visible = false;
			}
			else if ( checkSlotItem(0) == 12 )								// PISANG?		(FAIL)
			{
				/* set actor */
				setActor(m_foreground.pisang_1_fail);		
			}
			else if ( checkSlotItem(0) == 13 ){
				/* set actor */
				setActor(m_foreground.meat_1_fail);							// DAGING  (FAIL)
			}
			else if ( checkSlotItem(0) == 14 ){
				/* set actor */
				setActor(m_foreground.tongkat_1_fail);							// TONGKAT  (FAIL)
			}

			hideSlotItem(0);				
		}
		
		/* SIMULATION COMPLETE */
		override protected function simulationComplete():void 
		{
			super.simulationComplete();
			GameStateManager.getInstance().setState( GameState_Level_07.getInstance() );
		}
		
		/* EVENT ANIMASI */
		private function topeng1_success_done(event:Event):void 
		{
			m_owner.stage.removeEventListener("topeng_1_success_done", topeng1_success_done)
			m_foreground.suku_idle.visible = false;
			
			/* check slot 2 */
			
			if ( checkSlotItem(1) == 9 )									// TNT?		(SUCCESS)
			{
				/* set actor */
				setActor(m_foreground.tnt_2_success);
			}
			else if ( checkSlotItem(1) == 12 )								// PISANG?		(FAIL)
			{
				/* set actor */
				setActor(m_foreground.pisang_2_fail);			
			}
			else if ( checkSlotItem(1) == 13) 								// DAGING  (FAIL)
			{
				/* set actor */
				setActor(m_foreground.meat_2_fail)
			}
			else if ( checkSlotItem(1) == 14) 								// TONGKAT  (FAIL)
			{
				/* set actor */
				setActor(m_foreground.tongkat_2_fail)
			}
			
			hideSlotItem(1);
		}
		
		private function enterStageDone(event:Event):void {
			/*remove listener*/
			m_owner.stage.removeEventListener("enter_stage_done", enterStageDone);
			
			/*game started*/
			m_cutScene = false;
		}
		
		private function tnt2_success_done(event:Event):void
		{
			m_owner.stage.removeEventListener("tnt_2_success_done", tnt2_success_done );
			
			/* check slot 2 */
			
			if ( checkSlotItem(2) == 9 )									// TNT?		(SUCCESS)
			{
				/* set actor */
				m_foreground.munyuk_idle.visible = false;
				setActor(m_foreground.tnt_3_fail);
			}
			else if ( checkSlotItem(2) == 12 )								// PISANG?		(FAIL)
			{
				/* set actor */
				m_foreground.munyuk_idle.visible = false;
				setActor(m_foreground.pisang_3_fail);			
			}
			else if ( checkSlotItem(2) == 13) 								// DAGING  (SUCCESS)
			{
				/* set actor */
				m_foreground.munyuk_idle.visible = false;
				setActor(m_foreground.meat_3_success)
			}
			else if ( checkSlotItem(2) == 14) 								// TONGKAT  (FAIL)
			{
				/* set actor */
				m_foreground.munyuk_idle.visible = false;
				setActor(m_foreground.tongkat_3_fail)
			}
			
			hideSlotItem(2);
		}

		private function meat3_success_done(event:Event):void
		{
			m_owner.stage.removeEventListener("meat_3_success_done", meat3_success_done );
			
			if ( checkSlotItem(3) == 12 )									// PISANG?		(FAIL)
			{
				/* set actor */
				m_foreground.dino_idle.visible = false;
				setActor(m_foreground.pisang_4_fail);
			}
			else if ( checkSlotItem(3) == 14 )								// TONGKAT?		(SUCCESS)
			{
				/* set actor */
				m_foreground.dino_idle.visible = false;
				setActor(m_foreground.tongkat_4_success);			
			}
			else if ( checkSlotItem(3) == 9) 								// TNT  (FAIL)
			{
				/* set actor */
				m_foreground.dino_idle.visible = false;
				setActor(m_foreground.tnt_4_fail)
			}
			
			hideSlotItem(3);
		}
	
		private function tongkat4_success_done(event:Event):void
		{
			m_owner.stage.removeEventListener("tongkat_4_success_done", tongkat4_success_done)
			
			simulationComplete();
		}
		
		private function attemptFailed(event:Event):void
		{
			m_owner.stage.removeEventListener("tongkat_1_fail_done", attemptFailed);
			m_owner.stage.removeEventListener("meat_1_fail_done", attemptFailed);
			m_owner.stage.removeEventListener("tnt_1_fail_done", attemptFailed);
			m_owner.stage.removeEventListener("pisang_1_fail_done", attemptFailed);
			m_owner.stage.removeEventListener("tongkat_2_fail_done", attemptFailed);
			m_owner.stage.removeEventListener("pisang_2_fail_done", attemptFailed);
			m_owner.stage.removeEventListener("meat_2_fail_done", attemptFailed);
			m_owner.stage.removeEventListener("tongkat_3_fail_done", attemptFailed);
			m_owner.stage.removeEventListener("pisang_3_fail_done", attemptFailed);
			m_owner.stage.removeEventListener("tnt_3_fail_done", attemptFailed);
			m_owner.stage.removeEventListener("tnt_4_fail_done", attemptFailed);
			m_owner.stage.removeEventListener("pisang_4_fail_done", attemptFailed);
			
			
			gameOver( (event.type.toString() != "pisang_1_fail_done" &&
					   event.type.toString() != "tongkat_1_fail_done" &&
					   event.type.toString() != "tongkat_3_fail_done") );
					   
					   
			/* DINOSAUR LUNCH */
			if( !GlobalData.achievementDinoMeal )
			{
				if( event.type.toString() == "meat_1_fail_done" )
					GlobalData.dino1Eat = true;
				
				if( event.type.toString() == "pisang_4_fail_done" )
					GlobalData.dino2Eat = true;
					
				if( GlobalData.dino1Eat && GlobalData.dino2Eat )
				{
					GlobalData.achievementDinoMeal = true;
					achievementMessage(	GlobalData.achievementString["dinomeal"][0],
										GlobalData.achievementString["dinomeal"][1] );
										
					unlockNewgroundsMedal("Dino Meal");	
				}
				
				if ( GlobalData.achievementDinoMeal == true && 
					 GlobalData.ngMedals["Dino Meal"] != null &&
					 Medal(GlobalData.ngMedals["Dino Meal"]).unlocked == false )
					unlockNewgroundsMedal("Dino Meal");
					
				
				/* STICK VERSUS WILD */
				if ( !GlobalData.achievementStickVersusWild )	
				{
					GlobalData.eatenByDinosaur = true;
					
					if( GlobalData.eatenByDinosaur && GlobalData.eatenByCrab && 
						GlobalData.eatenByPiranha && GlobalData.eatenByCrocodile )	
					{
						GlobalData.achievementStickVersusWild = true;
						achievementMessage(	GlobalData.achievementString["stickVersusWild"][0],
											GlobalData.achievementString["stickVersusWild"][1] );
						
						unlockNewgroundsMedal("Stick vs Wild");
					}
				}
			}
						
			/* TNT VICTIM */
			if(	event.type.toString() == "tnt_1_fail_done" || 
				event.type.toString() == "tnt_3_fail_done" || 
				event.type.toString() == "tnt_4_fail_done" )
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
		
		static public function getInstance(): GameState_Level_06
		{
			if( m_instance == null ){
				m_instance = new GameState_Level_06( new SingletonLock() );
			}
			return m_instance;
		}
	}
}

class SingletonLock{}