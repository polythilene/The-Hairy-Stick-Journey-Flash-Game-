package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getTimer;
	import flash.display.Stage;
	
	/**
	 * ...
	 * @author Wiwit
	 */
	public class Main extends Sprite 
	{
		private var m_lastFrameTime:int;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			/* initialize sub-engine */
			ParticleManager.getInstance().initialize(stage.stageWidth, stage.stageHeight);
			ParticleManager.getInstance().registerEmitter( CEmitterForestMist, 1 );
			ParticleManager.getInstance().registerEmitter( CEmitterFallingLeaves, 1 );
			ParticleManager.getInstance().registerEmitter( CEmitterFireFlies, 1 );
			ParticleManager.getInstance().registerEmitter( CEmitterCaveDust, 1 );
			ParticleManager.getInstance().registerEmitter( CEmitterDessertDust, 1 );
			
			/* initialize vars */
			Serializer.getInstance().loadData();
			
			/* initialize states */
			GameState_BubbleBoxLogo.getInstance().initialize(this);
			GameState_BGLogo.getInstance().initialize(this);
			GameState_YouYouWinLogo.getInstance().initialize(this);
			GameState_ArmorGamesLogo.getInstance().initialize(this);
			GameState_GameMenu.getInstance().initialize(this);
			GameState_OpeningMovie.getInstance().initialize(this);
			GameState_Level_01.getInstance().initialize(this);
			GameState_Level_02.getInstance().initialize(this);
			GameState_Level_03.getInstance().initialize(this);
			GameState_Level_04.getInstance().initialize(this);
			GameState_Level_05.getInstance().initialize(this);
			GameState_Level_06.getInstance().initialize(this);
			GameState_Level_07.getInstance().initialize(this);
			GameState_Level_08.getInstance().initialize(this);
			GameState_Level_09.getInstance().initialize(this);
			GameState_Level_10.getInstance().initialize(this);
			GameState_EndingMovie.getInstance().initialize(this);
			
			/* register audio */
			SoundManager.getInstance().addMusic( "Music_DancesAndDames", new Music_DancesAndDames() );
			SoundManager.getInstance().addMusic( "Music_KoolKats", new Music_KoolKats() );
			SoundManager.getInstance().addMusic( "Music_FastTalkin", new Music_FastTalkin() );
			SoundManager.getInstance().addMusic( "Music_HotSwing", new Music_HotSwing() );
			
			/* register sfx */
			
			// level 01
			SoundManager.getInstance().addSFX( "SFX_FallFromSky", new sfx_fallFromSky() );
			SoundManager.getInstance().addSFX( "SFX_FallToCliff", new sfx_fallToCliff() );
			SoundManager.getInstance().addSFX( "SFX_PrepareRope", new sfx_prepareRope() );
			SoundManager.getInstance().addSFX( "SFX_SwingRope", new sfx_swingRope() );
			SoundManager.getInstance().addSFX( "SFX_ThrowRope", new sfx_throwRope() );
			
			// level 02
			SoundManager.getInstance().addSFX( "SFX_FallingRock", new sfx_fallingRock() );
			SoundManager.getInstance().addSFX( "SFX_Axe", new sfx_axe() );
			SoundManager.getInstance().addSFX( "SFX_FallingTree", new sfx_fallingTree() );
			SoundManager.getInstance().addSFX( "SFX_PickRock", new sfx_pickRock() );
			SoundManager.getInstance().addSFX( "SFX_Jump", new sfx_jump() );
			SoundManager.getInstance().addSFX( "SFX_Destroyed", new sfx_destroyed() );
			SoundManager.getInstance().addSFX( "SFX_AxeDamaged", new sfx_axeDamaged() );
			
			// level 3
			SoundManager.getInstance().addSFX( "SFX_Fall", new sfx_fall() );
			SoundManager.getInstance().addSFX( "SFX_Cannon", new sfx_cannon() );
			
			// level 4
			SoundManager.getInstance().addSFX( "SFX_BaloonRide", new sfx_baloonRide() );
			SoundManager.getInstance().addSFX( "SFX_Explode", new sfx_explode() );
			
			// level 5
			SoundManager.getInstance().addSFX( "SFX_FallSplat", new sfx_fallSplat() );
			SoundManager.getInstance().addSFX( "SFX_Trap", new sfx_trap() );
			SoundManager.getInstance().addSFX( "SFX_Throw", new sfx_throw() );
			SoundManager.getInstance().addSFX( "SFX_Eaten", new sfx_eaten() );
			
			// level 6
			SoundManager.getInstance().addSFX( "SFX_RollingStone", new sfx_rollingStone() );
			SoundManager.getInstance().addSFX( "SFX_Beam", new sfx_beam() );
			SoundManager.getInstance().addSFX( "SFX_RollingStone", new sfx_rollingStone() );
			SoundManager.getInstance().addSFX( "SFX_Dino", new sfx_dino() );
			SoundManager.getInstance().addSFX( "SFX_Slipped", new sfx_slipped() );
			SoundManager.getInstance().addSFX( "SFX_Monkey", new sfx_monkey() );
			
			// level 7
			SoundManager.getInstance().addSFX( "SFX_Crocodile", new sfx_crocodile() );
			SoundManager.getInstance().addSFX( "SFX_Splash", new sfx_splash() );
			SoundManager.getInstance().addSFX( "SFX_Drowning", new sfx_drowning() );
			SoundManager.getInstance().addSFX( "SFX_Piranha", new sfx_piranha() );
			SoundManager.getInstance().addSFX( "SFX_Bees", new sfx_bees() );
			
			// level 8
			SoundManager.getInstance().addSFX( "SFX_Worm", new sfx_worm() );
			
			// level 9
			SoundManager.getInstance().addSFX( "SFX_Bird", new sfx_bird() );
			SoundManager.getInstance().addSFX( "SFX_GiantWorm", new sfx_giantWorm() );
			SoundManager.getInstance().addSFX( "SFX_Taken", new sfx_taken() );
			SoundManager.getInstance().addSFX( "SFX_Saw", new sfx_saw() );
			SoundManager.getInstance().addSFX( "SFX_Mummy", new sfx_mummy() );
			SoundManager.getInstance().addSFX( "SFX_Sword", new sfx_sword() );
			
			// level 10
			SoundManager.getInstance().addSFX( "SFX_Alien", new sfx_alien() );
			SoundManager.getInstance().addSFX( "SFX_AlienByeBye", new sfx_alienByeBye() );
			SoundManager.getInstance().addSFX( "SFX_Flame", new sfx_flame() );
			SoundManager.getInstance().addSFX( "SFX_Grenade", new sfx_grenade() );
			SoundManager.getInstance().addSFX( "SFX_ScorpionAttack", new sfx_scorpionAttack() );
			SoundManager.getInstance().addSFX( "SFX_Mirror", new sfx_mirror() );
			SoundManager.getInstance().addSFX( "SFX_Laser", new sfx_laser() );
			
			// generic
			SoundManager.getInstance().addSFX( "SFX_StairStep", new sfx_stairStep() );
			SoundManager.getInstance().addSFX( "SFX_Button01", new sfx_button01() );
			SoundManager.getInstance().addSFX( "SFX_Button02", new sfx_button02() );
			SoundManager.getInstance().addSFX( "SFX_Button03", new sfx_button03() );
			SoundManager.getInstance().addSFX( "SFX_Button04", new sfx_button04() );
			
			SoundManager.getInstance().addSFX( "SFX_Chalk01", new sfx_chalk01() );
			SoundManager.getInstance().addSFX( "SFX_Chalk02", new sfx_chalk02() );
			SoundManager.getInstance().addSFX( "SFX_FallingBG", new sfx_fallingBG() );
			
			
			/* setup external sound player */
			Stage.prototype.playSFX = function(id:String):void 
										{ 
											SoundManager.getInstance().playSFX(id);
										};
			
			/* load global data */
			Serializer.getInstance().loadData();
			
			/* starting state */
			
			if( GlobalData.showBubbleBoxLogo )
				GameStateManager.getInstance().setState( GameState_BubbleBoxLogo.getInstance() );
			if( GlobalData.showArmorGamesLogo )
				GameStateManager.getInstance().setState( GameState_ArmorGamesLogo.getInstance() );
			else if ( GlobalData.showBelugerinLogo )
				GameStateManager.getInstance().setState( GameState_BGLogo.getInstance() );	
			else	
				GameStateManager.getInstance().setState( GameState_GameMenu.getInstance() );	
			
			/* start simulation */
			m_lastFrameTime = getTimer();
			stage.addEventListener(Event.ENTER_FRAME, updateScene);
		}
		
		private function updateScene(event:Event):void 
		{
			var elapsedTime:int=getTimer()-m_lastFrameTime;
			m_lastFrameTime += elapsedTime;
			
			GameStateManager.getInstance().update(elapsedTime);
		}
	}
}