package  
{
	import com.newgrounds.Medal;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	
	import com.newgrounds.API;
	
	import gs.*; 
	import gs.easing.*;

	public class GameState_GameMenu extends CGameState
	{
		static private var m_instance:GameState_GameMenu;
		
		public function GameState_GameMenu(lock:SingletonLock) {}
		
		
		/* objects */
		private var mc_ScreenGameMenu:ScreenGameMenu;
		private var mc_StartGameButton:StartGameButton;
		private var mc_ContinueGameButton:ContinueGameButton;
		private var mc_OptionsGameButton:OptionGameButton;
		private var mc_AchievementsGameButton:AchievementsGameButton;
		private var mc_CreditsGameButton:CreditsGameButton;
		
		private var mc_creditBox:CreditsScreen;
		private var mc_Achievements:Achievements;
		private var mc_BubbleBoxLogo:mcBubbleBoxLogo;
		private var mc_BGSLogo:mcBGSLogo;
		private var mc_AndkonLogo:mcAndkonLogo;
		private var mc_ArmorGamesLogo:mcArmorGames;
		
		private var m_menuFocused:Boolean;
		private var m_polaroids:Array;
		private var m_cancel:CancelPolaroid;
		private var m_music:CSoundObject;
		private var m_timer:Timer;
		
		private function registerButton(button:MovieClip):void
		{
			button.buttonMode = button.useHandCursor = true;
			
			button.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			button.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			button.addEventListener(MouseEvent.MOUSE_DOWN, onMouseClick);
		}
		
		private function unregisterButton(button:MovieClip):void
		{
			button.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			button.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			button.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseClick);
		}
		
		override public function initialize(owner:DisplayObjectContainer):void 
		{
			super.initialize(owner);
			m_polaroids = [];
			m_cancel = new CancelPolaroid();
			m_cancel.useHandCursor = m_cancel.buttonMode = true;
			
			for ( var i:int = 0; i < 10; i++ )
			{
				m_polaroids[i] = new StagePolaroid();
				MovieClip(m_polaroids[i]).gotoAndStop(i+1);
			}
			
			m_timer = new Timer(2000);
		}
		
		override public function enter():void 
		{
			super.enter();
			
			m_menuFocused = true;
			m_cancel.alpha = 0.75;
			
			//create new objects
			mc_ScreenGameMenu = new ScreenGameMenu();
			mc_StartGameButton = new StartGameButton();
			mc_ContinueGameButton = new ContinueGameButton();
			mc_OptionsGameButton = new OptionGameButton();
			mc_AchievementsGameButton = new AchievementsGameButton();
			mc_CreditsGameButton = new CreditsGameButton();
			
			//adding to screen
			m_owner.addChild(mc_ScreenGameMenu);
			m_owner.addChild(mc_StartGameButton);
			m_owner.addChild(mc_ContinueGameButton);
			m_owner.addChild(mc_OptionsGameButton);
			m_owner.addChild(mc_AchievementsGameButton);
			m_owner.addChild(mc_CreditsGameButton);
			
			if ( GlobalData.showYouYouWinLogo )
			{
				mc_ScreenGameMenu.judul.y = -180.0;
				TweenMax.to( mc_ScreenGameMenu.judul, 1, { y: -12.0, ease:Bounce.easeOut } );
			}
			
			if( GlobalData.showBubbleBoxLogo )
			{
				mc_BubbleBoxLogo = new mcBubbleBoxLogo();
				m_owner.addChild( mc_BubbleBoxLogo );
				
				mc_BubbleBoxLogo.scaleX = mc_BubbleBoxLogo.scaleY = 0.75;
				mc_BubbleBoxLogo.x = 577.5;
				mc_BubbleBoxLogo.y = 378.3;
				registerButton( mc_BubbleBoxLogo );
			}
				
			if( GlobalData.showBelugerinLogo )	
			{
				mc_BGSLogo = new mcBGSLogo();
				m_owner.addChild( mc_BGSLogo );
				
				mc_BGSLogo.scaleX = mc_BGSLogo.scaleY = 0.75;
				mc_BGSLogo.x = 37.5;
				mc_BGSLogo.y = 370.3;
				registerButton( mc_BGSLogo );
			}
				
			if( GlobalData.showAndkonLogo )	
			{	
				mc_AndkonLogo = new mcAndkonLogo();
				m_owner.addChild( mc_AndkonLogo ); 
				
				mc_AndkonLogo.x = 639.0;
				mc_AndkonLogo.y = 320.4;
				registerButton( mc_AndkonLogo );
			}
			
			if( GlobalData.showArmorGamesLogo )
			{
				mc_ArmorGamesLogo = new mcArmorGames();
				m_owner.addChild( mc_ArmorGamesLogo );
				
				mc_ArmorGamesLogo.x = 760;
				mc_ArmorGamesLogo.y = 320;
				registerButton( mc_ArmorGamesLogo );
			}
			
			//positioning button
			mc_StartGameButton.x = 694.1;
			mc_StartGameButton.y = 65.8;
			
			mc_ContinueGameButton.x = 589.4
			mc_ContinueGameButton.y = 84.7
			
			mc_OptionsGameButton.x = 599.7
			mc_OptionsGameButton.y = 140.8
			
			mc_AchievementsGameButton.x = 687.4
			mc_AchievementsGameButton.y = 113.7
			
			mc_CreditsGameButton.x = 675
			mc_CreditsGameButton.y = 161.7
			
			mc_creditBox = new CreditsScreen();
			addChild(mc_creditBox);
			mc_creditBox.visible = false;
			
			mc_Achievements = new Achievements();
			addChild(mc_Achievements);
			mc_Achievements.visible = false;
			
			//mouse over event
			registerButton( mc_creditBox.flipPage )
			registerButton(	mc_StartGameButton );
			registerButton(	mc_ContinueGameButton );
			registerButton(	mc_OptionsGameButton );
			registerButton(	mc_AchievementsGameButton );
			registerButton(	mc_CreditsGameButton );
			
			
			m_music = SoundManager.getInstance().playMusic( "Music_KoolKats", 1000 );
			
			GameOptions.getInstance().toggleResignButton(false);
			GameOptions.getInstance().addEventListener( GameOptions.AFTER_HIDE, menuOptionHidden );
			GameOptions.getInstance().addEventListener( GameOptions.BEFORE_SHOW, menuOptionShown );
		}
		
		override public function exit():void 
		{
			unregisterButton( mc_creditBox.flipPage )
			unregisterButton( mc_StartGameButton );
			unregisterButton( mc_ContinueGameButton );
			unregisterButton( mc_OptionsGameButton );
			unregisterButton( mc_AchievementsGameButton );
			unregisterButton( mc_CreditsGameButton );
			
			if( GlobalData.showBubbleBoxLogo )
			{
				m_owner.removeChild( mc_BubbleBoxLogo );
				unregisterButton( mc_BubbleBoxLogo );
			}
				
			if( GlobalData.showBelugerinLogo )
			{
				m_owner.removeChild(mc_BGSLogo);
				unregisterButton( mc_BGSLogo );
			}
			
			if( GlobalData.showAndkonLogo )
			{
				m_owner.removeChild( mc_AndkonLogo );
				unregisterButton( mc_AndkonLogo );
			}
			
			if( GlobalData.showArmorGamesLogo )
			{
				m_owner.removeChild( mc_ArmorGamesLogo );
				unregisterButton( mc_ArmorGamesLogo );
			}
			
			GameOptions.getInstance().removeEventListener( GameOptions.AFTER_HIDE,  menuOptionHidden );
			GameOptions.getInstance().removeEventListener( GameOptions.BEFORE_SHOW, menuOptionShown );
			
			//remove from screen
			m_owner.removeChild(mc_AchievementsGameButton);
			m_owner.removeChild(mc_ContinueGameButton);
			m_owner.removeChild(mc_CreditsGameButton);
			m_owner.removeChild(mc_StartGameButton);
			m_owner.removeChild(mc_OptionsGameButton);
			m_owner.removeChild(mc_ScreenGameMenu);
			
			mc_StartGameButton = null;
			mc_ScreenGameMenu = null;
			
			m_music.stop();
		}
		
		override public function update(elapsedTime:int):void 
		{
			
		}
		
		public function onMouseOver(e:MouseEvent):void 
		{
			/* GAME MENU */
			if ( m_menuFocused )
			{
				SoundManager.getInstance().playSFX("SFX_Button01");
				
				var mc:MovieClip = MovieClip(e.currentTarget);
				var color:int = ( mc == mc_BubbleBoxLogo || mc == mc_BGSLogo ) ? 0xffffcc : 0xffff00;
				var blur:int = ( mc == mc_BubbleBoxLogo || mc == mc_BGSLogo ) ? 15 : 5;
				
				TweenMax.to(mc, 0.5, { glowFilter: { color:color, alpha:1, blurX:blur, blurY:blur, strength:2 }} );
			}
		}
		
		public function onMouseOut(e:MouseEvent):void 
		{
			/* GAME MENU */
			if ( m_menuFocused )
			{
				var mc:MovieClip = MovieClip(e.currentTarget);
				var color:int = ( mc == mc_BubbleBoxLogo || mc == mc_BGSLogo ) ? 0xffffcc : 0xffff00;

				TweenMax.to(mc, 0.5, { glowFilter: { color:color, alpha:1, blurX:0, blurY:0, strength:0 }} );
			}
		}
		
		public function onMouseClick(e:MouseEvent):void 
		{
			if ( m_menuFocused )
			{
				SoundManager.getInstance().playSFX("SFX_Button03");
				
				var mc:MovieClip = MovieClip(e.currentTarget);
				TweenMax.to(mc, 0.5, {glowFilter:{color:0xffff00, alpha:0, blurX:0, blurY:0, strength:0}});
				
				if ( e.currentTarget == mc_StartGameButton )
				{
					resetCurrentPlayData();
					GlobalData.showTutorial = true;
					GameStateManager.getInstance().setState(GameState_OpeningMovie.getInstance());
				}
				else if ( e.currentTarget == mc_ContinueGameButton )
				{
					m_menuFocused = false;
					toggleMenu(false);
					showPolaroids();
				}
				else if ( e.currentTarget == mc_OptionsGameButton )
				{
					GameOptions.getInstance().show(m_owner.stage);
				}
				else if ( e.currentTarget == mc_AchievementsGameButton )
				{
					toggleMenu(false);
					showAchievements();
				}
				else if ( e.currentTarget == mc_CreditsGameButton )
				{
					TweenMax.killTweensOf(mc_creditBox);
					m_menuFocused = false;
					mc_creditBox.x = 400;
					mc_creditBox.y = -400;
					mc_creditBox.visible = true;
					mc_creditBox.gotoAndStop(1);
					TweenMax.to(mc_creditBox, 1, { y:200, ease:Bounce.easeOut } );
					
					toggleMenu(false);
					TweenMax.to( mc_ScreenGameMenu, 1, { blurFilter: { blurX:8, blurY:8 } } );
				}
			}
			

			if ( e.currentTarget == mc_creditBox.flipPage )
			{
				if (mc_creditBox.currentFrame < 3)
				{
					mc_creditBox.gotoAndStop(mc_creditBox.currentFrame + 1);
				}
				else
				{
					m_menuFocused = true;
					TweenMax.to(mc_creditBox, 1, { y: -400, ease:Bounce.easeOut, onComplete:function():void { mc_creditBox.visible = false; } } );
					TweenMax.to( mc_ScreenGameMenu, 1, { blurFilter: { blurX:0, blurY:0 } } );
					
					toggleMenu(true);
				}
			}
			else if ( mc_BubbleBoxLogo != null && e.currentTarget == mc_BubbleBoxLogo )
			{
				navigateTo("http://www.bubblebox.com/clickreg.php?type=gamestats&id=1823&subid=mainmenu");
			}
            else if ( mc_BGSLogo != null && e.currentTarget == mc_BGSLogo )
			{
				navigateTo("http://www.belugerinstudios.com");
			}
			else if ( mc_AndkonLogo != null && e.currentTarget == mc_AndkonLogo )
			{
				navigateTo("http://www.andkon.com/arcade/");
			}
			else if ( mc_ArmorGamesLogo != null && e.currentTarget == mc_ArmorGamesLogo )
			{
				navigateTo("http://www.armorgames.com/");
			}
		}
		
		private function menuOptionShown(event:Event):void
		{
			TweenMax.killTweensOf( mc_ScreenGameMenu, true );
			m_menuFocused = false;
			toggleMenu(false);
			TweenMax.to( mc_ScreenGameMenu, 1, { blurFilter: { blurX:8, blurY:8 } } );
		}
		
		private function menuOptionHidden(event:Event):void
		{
			TweenMax.killTweensOf( mc_ScreenGameMenu, true );
			m_menuFocused = true;
			toggleMenu(true);
			TweenMax.to( mc_ScreenGameMenu, 0.25, { blurFilter: { blurX:0, blurY:0 } } );
		}
		
		private function toggleMenu(menu_visible:Boolean = true):void
		{
			mc_StartGameButton.visible = menu_visible;
			mc_ContinueGameButton.visible = menu_visible;
			mc_OptionsGameButton.visible = menu_visible;
			mc_AchievementsGameButton.visible = menu_visible;
			mc_CreditsGameButton.visible = menu_visible;
		}
		
		private function resetCurrentPlayData():void
		{
			/* reset game data */
			GlobalData.levelFailCount = 0;
			
			if ( !GlobalData.achievementDinoMeal )
			{
				GlobalData.dino1Eat = GlobalData.dino2Eat = false;
			}
		}
		
		private function showPolaroids():void
		{
			TweenMax.killAllTweens(true);
			
			TweenMax.to( mc_ScreenGameMenu, 1, { blurFilter: { blurX:8, blurY:8 } } );
			m_timer.stop();
			
			var start_x:int = 118;
			var start_y:int = 154;
			
			var curr_x:int = start_x;
			var curr_y:int = start_y;
			var mc:MovieClip;
			var index:int = 0;
			
			m_owner.addChild(m_cancel);
			m_cancel.x = 400;
			m_cancel.y = 410;
			m_cancel.scaleX = m_cancel.scaleY = 1;
			registerPolaroids(m_cancel);
			
			for (var y:int = 0; y < 2; y++)
			{
				for (var x:int = 0; x < 5; x++)
				{
					mc = m_polaroids[index];
					m_owner.addChild(mc);
					
					registerPolaroids(mc);
					mc.visible = GlobalData.levelAccess[index];
					mc.useHandCursor = mc.buttonMode = true;
					
					mc.x = 800 + randomRange(100, 300);
					mc.y = 450 + randomRange(100, 300);;
				
					TweenMax.to(mc, randomRange(0.5, 1.0), { x:curr_x, y:curr_y, onComplete:function():void { SoundManager.getInstance().playSFX("SFX_StairStep"); } } );
					curr_x += 141;
					index++;
				}	
				
				curr_x = start_x;
				curr_y += 187;
			}
		}
		
		private function hidePolaroids():void
		{
			TweenMax.killTweensOf(mc_creditBox);
			TweenMax.to( mc_ScreenGameMenu, 1, { blurFilter: { blurX:0, blurY:0 } } );
			
			var mc:MovieClip;
			var index:int = 0;
			
			m_owner.removeChild(m_cancel);
			unregisterPolaroids(m_cancel);
			
			for (var y:int = 0; y < 2; y++)
			{
				for (var x:int = 0; x < 5; x++)
				{
					
					mc = m_polaroids[index];
					
					TweenMax.killTweensOf(mc);
					unregisterPolaroids(mc);
					
					TweenMax.to(mc, randomRange(0.25, 0.75), 
								{ x:800 + randomRange(100, 300), 
								  y:450 + randomRange(100, 300)	} );
					index++;
				}	
			}
			
			m_timer.addEventListener(TimerEvent.TIMER, removePolaroids);
			m_timer.start();
		}
		
		
		private function removePolaroids(event:TimerEvent):void
		{
			m_timer.removeEventListener(TimerEvent.TIMER, removePolaroids);
			var index:int = 0;
			var mc:MovieClip = new MovieClip();
			
			for (var y:int = 0; y < 2; y++)
			{
				for (var x:int = 0; x < 5; x++)
				{
					mc = m_polaroids[index];
					m_owner.removeChild(mc);
					index++;
				}	
			}
		}
		
		private function registerPolaroids(button:MovieClip):void
		{
			button.addEventListener(MouseEvent.MOUSE_OVER, onPolaroidMouseOver);
			button.addEventListener(MouseEvent.MOUSE_OUT, onPolaroidMouseOut);
			button.addEventListener(MouseEvent.MOUSE_DOWN, onPolaroidMouseClick);
		}
		
		private function unregisterPolaroids(button:MovieClip):void
		{
			button.removeEventListener(MouseEvent.MOUSE_OVER, onPolaroidMouseOver);
			button.removeEventListener(MouseEvent.MOUSE_OUT, onPolaroidMouseOut);
			button.removeEventListener(MouseEvent.MOUSE_DOWN, onPolaroidMouseClick);
		}
		
		private function onPolaroidMouseOver(event:MouseEvent):void
		{
			var mc:MovieClip = MovieClip(event.currentTarget);
			
			TweenMax.to(mc, 0.5, { scaleX:1.2, scaleY:1.2, glowFilter: { color:0xffff00, alpha:1, blurX:20, blurY:20 } } );
		}
		
		private function onPolaroidMouseOut(event:MouseEvent):void
		{
			var mc:MovieClip = MovieClip(event.currentTarget);
			
			if ( event.currentTarget == m_cancel )
				TweenMax.to(mc, 1, { scaleX:1, scaleY:1, /*alpha:0.5, */glowFilter: { color:0xffff00, alpha:0.5, blurX:0, blurY:0 } } );
			else	
				TweenMax.to(mc, 1, { scaleX:1, scaleY:1, glowFilter: { color:0xffff00, blurX:0, blurY:0 } } );
		}
		
		private function onPolaroidMouseClick(event:MouseEvent):void
		{
			hidePolaroids();
			resetCurrentPlayData();
			
			if( event.currentTarget == MovieClip(m_polaroids[0]) )
				GameStateManager.getInstance().setState(GameState_Level_01.getInstance());
			else if( event.currentTarget == MovieClip(m_polaroids[1]) )
				GameStateManager.getInstance().setState(GameState_Level_02.getInstance());
			else if( event.currentTarget == MovieClip(m_polaroids[2]) )
				GameStateManager.getInstance().setState(GameState_Level_03.getInstance());
			else if( event.currentTarget == MovieClip(m_polaroids[3]) )
				GameStateManager.getInstance().setState(GameState_Level_04.getInstance());
			else if( event.currentTarget == MovieClip(m_polaroids[4]) )
				GameStateManager.getInstance().setState(GameState_Level_05.getInstance());
			else if( event.currentTarget == MovieClip(m_polaroids[5]) )
				GameStateManager.getInstance().setState(GameState_Level_06.getInstance());
			else if( event.currentTarget == MovieClip(m_polaroids[6]) )
				GameStateManager.getInstance().setState(GameState_Level_07.getInstance());
			else if( event.currentTarget == MovieClip(m_polaroids[7]) )
				GameStateManager.getInstance().setState(GameState_Level_08.getInstance());
			else if( event.currentTarget == MovieClip(m_polaroids[8]) )
				GameStateManager.getInstance().setState(GameState_Level_09.getInstance());
			else if( event.currentTarget == MovieClip(m_polaroids[9]) )
				GameStateManager.getInstance().setState(GameState_Level_10.getInstance());
			else
			{
				m_menuFocused = true;
				toggleMenu(true);
			}
		}
		
		private function showAchievements():void
		{
			m_menuFocused = false;
			
			mc_Achievements.x = 400;
			mc_Achievements.y = -400;
			mc_Achievements.visible = mc_Achievements.buttonMode = mc_Achievements.useHandCursor = true;
			
			if ( GlobalData.newgroundsAPI )
			{
				var medal:Medal;
				
				medal = Medal(GlobalData.ngMedals["First Blood"]);
				mc_Achievements.firstBlood.gotoAndStop( (medal != null && medal.unlocked) ? 2 : 1 );
				
				medal = Medal(GlobalData.ngMedals["Dead Stick"]);
				mc_Achievements.iSeeDeadStick.gotoAndStop( (medal != null && medal.unlocked) ? 2 : 1 );
				
				medal = Medal(GlobalData.ngMedals["Flawless"]);
				mc_Achievements.flawless.gotoAndStop( (medal != null && medal.unlocked) ? 2 : 1 );
				
				medal = Medal(GlobalData.ngMedals["Dino Meal"]);
				mc_Achievements.dinoMeal.gotoAndStop( (medal != null && medal.unlocked) ? 2 : 1 );
				
				medal = Medal(GlobalData.ngMedals["TNT Victim"]);
				mc_Achievements.tntVictim.gotoAndStop( (medal != null && medal.unlocked) ? 2 : 1 );
				
				medal = Medal(GlobalData.ngMedals["Being Evil"]);
				mc_Achievements.beingEvil.gotoAndStop( (medal != null && medal.unlocked) ? 2 : 1 );
				
				medal = Medal(GlobalData.ngMedals["Stick vs Wild"]);
				mc_Achievements.stickVersusWild.gotoAndStop( (medal != null && medal.unlocked) ? 2 : 1 );
				
				medal = Medal(GlobalData.ngMedals["Finaly Home"]);
				mc_Achievements.finallyHome.gotoAndStop( (medal != null && medal.unlocked) ? 2 : 1 );
				
				medal = Medal(GlobalData.ngMedals["Movie Freak"]);
				mc_Achievements.movieFreak.gotoAndStop( (medal != null && medal.unlocked) ? 2 : 1 );
			}
			else
			{
				mc_Achievements.firstBlood.gotoAndStop( (GlobalData.achievementFirstBlood) ? 2 : 1 );
				mc_Achievements.iSeeDeadStick.gotoAndStop( (GlobalData.achievementISeeDeadStick) ? 2 : 1 );
				mc_Achievements.flawless.gotoAndStop( (GlobalData.achievementFlawless) ? 2 : 1 );
				mc_Achievements.dinoMeal.gotoAndStop( (GlobalData.achievementDinoMeal) ? 2 : 1 );
				mc_Achievements.tntVictim.gotoAndStop( (GlobalData.achievementTNTVictim) ? 2 : 1 );
				mc_Achievements.beingEvil.gotoAndStop( (GlobalData.achievementBeingEvil) ? 2 : 1 );
				mc_Achievements.stickVersusWild.gotoAndStop( (GlobalData.achievementStickVersusWild) ? 2 : 1 );
				mc_Achievements.finallyHome.gotoAndStop( (GlobalData.achievementFinallyHome) ? 2 : 1 );
				mc_Achievements.movieFreak.gotoAndStop( (GlobalData.achievementMovieFreak) ? 2 : 1 );
			}
			
			mc_Achievements.firstBlood.addEventListener(MouseEvent.MOUSE_OVER, achievementDescOver);
			mc_Achievements.iSeeDeadStick.addEventListener(MouseEvent.MOUSE_OVER, achievementDescOver);
			mc_Achievements.flawless.addEventListener(MouseEvent.MOUSE_OVER, achievementDescOver);
			mc_Achievements.dinoMeal.addEventListener(MouseEvent.MOUSE_OVER, achievementDescOver);
			mc_Achievements.tntVictim.addEventListener(MouseEvent.MOUSE_OVER, achievementDescOver);
			mc_Achievements.beingEvil.addEventListener(MouseEvent.MOUSE_OVER, achievementDescOver);
			mc_Achievements.stickVersusWild.addEventListener(MouseEvent.MOUSE_OVER, achievementDescOver);
			mc_Achievements.finallyHome.addEventListener(MouseEvent.MOUSE_OVER, achievementDescOver);
			mc_Achievements.movieFreak.addEventListener(MouseEvent.MOUSE_OVER, achievementDescOver);
			
			mc_Achievements.firstBlood.addEventListener(MouseEvent.MOUSE_OUT, achievementDescOut);
			mc_Achievements.iSeeDeadStick.addEventListener(MouseEvent.MOUSE_OUT, achievementDescOut);
			mc_Achievements.flawless.addEventListener(MouseEvent.MOUSE_OUT, achievementDescOut);
			mc_Achievements.dinoMeal.addEventListener(MouseEvent.MOUSE_OUT, achievementDescOut);
			mc_Achievements.tntVictim.addEventListener(MouseEvent.MOUSE_OUT, achievementDescOut);
			mc_Achievements.beingEvil.addEventListener(MouseEvent.MOUSE_OUT, achievementDescOut);
			mc_Achievements.stickVersusWild.addEventListener(MouseEvent.MOUSE_OUT, achievementDescOut);
			mc_Achievements.finallyHome.addEventListener(MouseEvent.MOUSE_OUT, achievementDescOut);
			mc_Achievements.movieFreak.addEventListener(MouseEvent.MOUSE_OUT, achievementDescOut);
			
			TweenMax.to( mc_Achievements, 1, { y:177.3, ease:Bounce.easeOut } );
			mc_Achievements.closeButton.addEventListener(MouseEvent.CLICK, onAchievementClick);
			
			TweenMax.to( mc_ScreenGameMenu, 1, { blurFilter: { blurX:8, blurY:8 } } );
		}
		
		private function onAchievementClick(event:MouseEvent):void
		{
			mc_Achievements.closeButton.removeEventListener(MouseEvent.CLICK, onAchievementClick);
			
			mc_Achievements.firstBlood.removeEventListener(MouseEvent.MOUSE_OVER, achievementDescOver);
			mc_Achievements.iSeeDeadStick.removeEventListener(MouseEvent.MOUSE_OVER, achievementDescOver);
			mc_Achievements.flawless.removeEventListener(MouseEvent.MOUSE_OVER, achievementDescOver);
			mc_Achievements.dinoMeal.removeEventListener(MouseEvent.MOUSE_OVER, achievementDescOver);
			mc_Achievements.tntVictim.removeEventListener(MouseEvent.MOUSE_OVER, achievementDescOver);
			mc_Achievements.beingEvil.removeEventListener(MouseEvent.MOUSE_OVER, achievementDescOver);
			mc_Achievements.stickVersusWild.removeEventListener(MouseEvent.MOUSE_OVER, achievementDescOver);
			mc_Achievements.finallyHome.removeEventListener(MouseEvent.MOUSE_OVER, achievementDescOver);
			mc_Achievements.movieFreak.removeEventListener(MouseEvent.MOUSE_OVER, achievementDescOver);
			
			mc_Achievements.firstBlood.removeEventListener(MouseEvent.MOUSE_OUT, achievementDescOut);
			mc_Achievements.iSeeDeadStick.removeEventListener(MouseEvent.MOUSE_OUT, achievementDescOut);
			mc_Achievements.flawless.removeEventListener(MouseEvent.MOUSE_OUT, achievementDescOut);
			mc_Achievements.dinoMeal.removeEventListener(MouseEvent.MOUSE_OUT, achievementDescOut);
			mc_Achievements.tntVictim.removeEventListener(MouseEvent.MOUSE_OUT, achievementDescOut);
			mc_Achievements.beingEvil.removeEventListener(MouseEvent.MOUSE_OUT, achievementDescOut);
			mc_Achievements.stickVersusWild.removeEventListener(MouseEvent.MOUSE_OUT, achievementDescOut);
			mc_Achievements.finallyHome.removeEventListener(MouseEvent.MOUSE_OUT, achievementDescOut);
			mc_Achievements.movieFreak.removeEventListener(MouseEvent.MOUSE_OUT, achievementDescOut);
			
			TweenMax.to( mc_ScreenGameMenu, 1, { blurFilter: { blurX:0, blurY:0 } } );
			TweenMax.to( mc_Achievements, 1, { y: -400, onComplete:function():void { m_menuFocused = true; } } );
			toggleMenu(true);
		}
		
		private function achievementDescOver(event:MouseEvent):void
		{
			var mc:MovieClip = MovieClip(event.currentTarget);
			
			switch( mc )
			{
				case mc_Achievements.firstBlood:
						mc_Achievements.desc.htmlText = "First time dead.";
						break;
				case mc_Achievements.iSeeDeadStick:
						mc_Achievements.desc.htmlText = "3X Dead.";
						break;
				case mc_Achievements.flawless:
						mc_Achievements.desc.htmlText = "Completing a level without accident.";
						break;
				case mc_Achievements.dinoMeal:
						mc_Achievements.desc.htmlText = "Eaten by dinosaurs.";
						break;
				case mc_Achievements.tntVictim:
						mc_Achievements.desc.htmlText = "Killed by TNTs.";
						break;
				case mc_Achievements.beingEvil:
						mc_Achievements.desc.htmlText = "Use a chainsaw.";
						break;
				case mc_Achievements.stickVersusWild:
						mc_Achievements.desc.htmlText = "Killed by various animals.";
						break;
				case mc_Achievements.finallyHome:
						mc_Achievements.desc.htmlText = "Help harry find his way home.";
						break;
				case mc_Achievements.movieFreak:
						mc_Achievements.desc.htmlText = "View opening and ending movie until its finish.";
						break;
			}
		}
		
		private function achievementDescOut(event:MouseEvent):void
		{
			mc_Achievements.desc.htmlText = "";
		}
		
		/* ============================
		 * 			SINGLETON
		 * ============================
		 */
		
		static public function getInstance(): GameState_GameMenu
		{
			if( m_instance == null ){
				m_instance = new GameState_GameMenu( new SingletonLock() );
			}
			return m_instance;
		}
	}
}

class SingletonLock{}