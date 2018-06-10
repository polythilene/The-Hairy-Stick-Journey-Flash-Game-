package  
{
	/* TODO: DEFINE INITIALIZATION WHEN WINDOW SHOWED */
	 
	import flash.display.Stage;
	import flash.display.StageQuality;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.filters.GlowFilter;
	import flash.ui.Mouse;
	
	import gs.TweenMax;
	import gs.easing.*;
	
	/**
	 * ...
	 * @author Kurniawan Fitriadi
	 */
	public class GameOptions extends EventDispatcher
	{
		static private var m_instance:GameOptions;
		
		/* constants */
		static public const BEFORE_SHOW:String = "before_show";
		static public const AFTER_HIDE:String = "after_hide";
		static public const RESIGN:String = "resign";
		
		/* buffers */
		private var m_inGameMenu:InGameMenu;
		private var m_dragTarget:MovieClip;
		private var m_volumeSliderRect:Rectangle;
		private var m_sfxSliderRect:Rectangle;
		private var m_dragging:Boolean;
		private var m_stage:Stage;
		private var m_showInstant:Boolean;
		
		public function GameOptions(lock:SingletonLock) 
		{ 
			initialize();
		}
		
		public function initialize():void
		{
			m_inGameMenu = new InGameMenu();	// in-game menu
			
			
			/* init music bar */
			
			m_inGameMenu.musicVolume.bar.stop();
			var rect:Rectangle = new Rectangle(0, -10, 145, 50);
			m_volumeSliderRect = new Rectangle(	rect.x + 10, 
												m_inGameMenu.musicVolume.musicSliderButton.y,
												rect.width - 20, 0 );
			
			// calculate percentage 
			var max:Number = Math.round(m_volumeSliderRect.width);
			var vol:Number = SoundManager.getInstance().musicVolume;

			m_inGameMenu.musicVolume.musicSliderButton.x = vol * max;
			m_inGameMenu.musicVolume.bar.gotoAndStop(vol * 100);
			
			/* init sound option */
			if ( SoundManager.getInstance().sfxEnable )
			{
				m_inGameMenu.sfxOn.gotoAndStop(1);
				m_inGameMenu.sfxOff.gotoAndStop(2);
			}
			else	
			{
				m_inGameMenu.sfxOn.gotoAndStop(2);
				m_inGameMenu.sfxOff.gotoAndStop(1);
			}	
			
			/* init anim speed */
			m_inGameMenu.speed1X.gotoAndStop(1);
			m_inGameMenu.speed15X.gotoAndStop(2);
			m_inGameMenu.speed2X.gotoAndStop(2);
			
			/*
			ParticleManager.getInstance().addEventListener(ParticleManager.PARTICLE_ENABLED, particleOn);
			ParticleManager.getInstance().addEventListener(ParticleManager.PARTICLE_DISABLED, particleOff);
			*/
		}
		
		public function toggleResignButton(visible:Boolean):void
		{
			m_inGameMenu.resign.visible = visible;
		}
		
		public function show(stage:Stage, instant:Boolean=false, instant_x:int = 400, instant_y:int = 225):void
		{
			TweenMax.killTweensOf(m_inGameMenu, true);
			
			dispatchEvent( new Event(BEFORE_SHOW) );
			
			m_stage = stage;
			m_stage.addChild(m_inGameMenu);

			m_dragTarget = null;
			m_dragging = false;
			m_showInstant = instant;
			
			
			var qty:String = m_stage.quality.toLowerCase();
			
			if( qty == StageQuality.LOW.toLowerCase() )
			{
				m_inGameMenu.gfxLow.gotoAndStop(1);
				m_inGameMenu.gfxMed.gotoAndStop(2);
				m_inGameMenu.gfxHigh.gotoAndStop(2);
			}
			else if( qty == StageQuality.MEDIUM.toLowerCase() )
			{
				m_inGameMenu.gfxLow.gotoAndStop(2);
				m_inGameMenu.gfxMed.gotoAndStop(1);
				m_inGameMenu.gfxHigh.gotoAndStop(2);
			}	
			else if( qty == StageQuality.BEST.toLowerCase() ||
					 qty == StageQuality.HIGH.toLowerCase() )
			{
				m_inGameMenu.gfxLow.gotoAndStop(2);
				m_inGameMenu.gfxMed.gotoAndStop(2);
				m_inGameMenu.gfxHigh.gotoAndStop(1);
			}
			
			if (instant)
			{
				m_inGameMenu.x = instant_x;
				m_inGameMenu.y = instant_y;
				registerMenuHandler();
			}
			else
			{
				m_inGameMenu.x = 400;
				m_inGameMenu.y = -500;
				
				TweenMax.to( m_inGameMenu, 2, 
							{ 
								x:400, y:225, 
								ease:Bounce.easeOut,
								onComplete:function():void
								{
									registerMenuHandler();
								}
							} );
			}
		}
		
		private function registerMenuHandler():void
		{
			m_inGameMenu.musicVolume.musicSliderButton.buttonMode = 
			m_inGameMenu.musicVolume.musicSliderButton.useHandCursor = true;
			m_inGameMenu.musicVolume.musicSliderButton.addEventListener(MouseEvent.MOUSE_DOWN, inGameSliderDown);
			m_stage.addEventListener(MouseEvent.MOUSE_UP, inGameSliderUp);
			m_stage.addEventListener(MouseEvent.MOUSE_MOVE, inGameMouseMove);
			
			m_inGameMenu.gfxLow.buttonMode = m_inGameMenu.gfxLow.useHandCursor = true;
			m_inGameMenu.gfxMed.buttonMode = m_inGameMenu.gfxMed.useHandCursor = true;
			m_inGameMenu.gfxHigh.buttonMode = m_inGameMenu.gfxHigh.useHandCursor = true;
			
			m_inGameMenu.gfxLow.addEventListener(MouseEvent.CLICK, gfxSet);
			m_inGameMenu.gfxMed.addEventListener(MouseEvent.CLICK, gfxSet);
			m_inGameMenu.gfxHigh.addEventListener(MouseEvent.CLICK, gfxSet);
			
			m_inGameMenu.sfxOn.buttonMode = m_inGameMenu.sfxOn.useHandCursor = true;
			m_inGameMenu.sfxOff.buttonMode = m_inGameMenu.sfxOff.useHandCursor = true;
			
			m_inGameMenu.sfxOn.addEventListener(MouseEvent.CLICK, sfxSet);
			m_inGameMenu.sfxOff.addEventListener(MouseEvent.CLICK, sfxSet);
			
			m_inGameMenu.back.buttonMode = m_inGameMenu.back.useHandCursor = true;
			m_inGameMenu.resign.buttonMode = m_inGameMenu.resign.useHandCursor = true;
		
			m_inGameMenu.back.addEventListener(MouseEvent.MOUSE_OVER, onButtonHover);
			m_inGameMenu.back.addEventListener(MouseEvent.MOUSE_OUT, onButtonOut);
			m_inGameMenu.back.addEventListener(MouseEvent.CLICK, onButtonClick);
			
			m_inGameMenu.resign.addEventListener(MouseEvent.MOUSE_OVER, onButtonHover);
			m_inGameMenu.resign.addEventListener(MouseEvent.MOUSE_OUT, onButtonOut);
			m_inGameMenu.resign.addEventListener(MouseEvent.CLICK, onButtonClick);
			
			m_inGameMenu.speed1X.buttonMode = m_inGameMenu.speed15X.buttonMode = m_inGameMenu.speed2X.buttonMode = 
			m_inGameMenu.speed1X.useHandCursor = m_inGameMenu.speed15X.useHandCursor = m_inGameMenu.speed2X.useHandCursor = true;
			
			m_inGameMenu.speed1X.addEventListener(MouseEvent.CLICK, onSpeedChange);
			m_inGameMenu.speed15X.addEventListener(MouseEvent.CLICK, onSpeedChange);
			m_inGameMenu.speed2X.addEventListener(MouseEvent.CLICK, onSpeedChange);
		}
		
		private function unregisterMenuHandler():void
		{
			m_inGameMenu.musicVolume.musicSliderButton.removeEventListener(MouseEvent.MOUSE_DOWN, inGameSliderDown);
			m_stage.removeEventListener(MouseEvent.MOUSE_UP, inGameSliderUp);
			m_stage.removeEventListener(MouseEvent.MOUSE_MOVE, inGameMouseMove);
			
			m_inGameMenu.gfxLow.removeEventListener(MouseEvent.CLICK, gfxSet);
			m_inGameMenu.gfxMed.removeEventListener(MouseEvent.CLICK, gfxSet);
			m_inGameMenu.gfxHigh.removeEventListener(MouseEvent.CLICK, gfxSet);
			
			m_inGameMenu.sfxOn.removeEventListener(MouseEvent.CLICK, sfxSet);
			m_inGameMenu.sfxOff.removeEventListener(MouseEvent.CLICK, sfxSet);
			
			m_inGameMenu.back.removeEventListener(MouseEvent.MOUSE_OVER, onButtonHover);
			m_inGameMenu.back.removeEventListener(MouseEvent.MOUSE_OUT, onButtonHover);
			m_inGameMenu.back.removeEventListener(MouseEvent.CLICK, onButtonClick);
			
			m_inGameMenu.resign.removeEventListener(MouseEvent.MOUSE_OVER, onButtonHover);
			m_inGameMenu.resign.removeEventListener(MouseEvent.MOUSE_OUT, onButtonOut);
			m_inGameMenu.resign.removeEventListener(MouseEvent.CLICK, onButtonClick);
			
			m_inGameMenu.speed1X.removeEventListener(MouseEvent.CLICK, onSpeedChange);
			m_inGameMenu.speed15X.removeEventListener(MouseEvent.CLICK, onSpeedChange);
			m_inGameMenu.speed2X.removeEventListener(MouseEvent.CLICK, onSpeedChange);
		}
		
		public function hide(instant:Boolean=false):void
		{
			TweenMax.killTweensOf(m_inGameMenu, true);
			
			unregisterMenuHandler();
			m_showInstant = instant;
			
			if ( m_showInstant )
			{
				m_stage.removeChild(m_inGameMenu);
				dispatchEvent( new Event(AFTER_HIDE) );	
				dispatchEvent( new Event(RESIGN) );
			}
			else
			{
				TweenMax.to( m_inGameMenu, 1.0, 
							{ 
								x:400, y:-500,
								/*ease:Bounce.easeIn,*/
								onComplete:function():void
								{
									m_stage.removeChild(m_inGameMenu);
									dispatchEvent( new Event(AFTER_HIDE) );	
								}
							} );
			}
		}
		
		private function onButtonHover(event:MouseEvent):void
		{
			var mc:MovieClip = MovieClip(event.currentTarget);
			mc.scaleX = mc.scaleY = 1.25;
		}
		
		private function onButtonOut(event:MouseEvent):void
		{
			var mc:MovieClip = MovieClip(event.currentTarget);
			mc.scaleX = mc.scaleY = 1.0;
		}
		
		private function onButtonClick(event:MouseEvent):void
		{
			var mc:MovieClip = MovieClip(event.currentTarget);
			
			if( mc == m_inGameMenu.back )
				hide();
			else
			{
				hide(true);
				GameStateManager.getInstance().setState( GameState_GameMenu.getInstance() );
			}
			
			m_inGameMenu.back.scaleX = m_inGameMenu.back.scaleY = 1.0;
			
		}
		
		private function onSpeedChange(event:MouseEvent):void
		{
			m_inGameMenu.speed1X.gotoAndStop(2);
			m_inGameMenu.speed15X.gotoAndStop(2);
			m_inGameMenu.speed2X.gotoAndStop(2);
			
			var mc:MovieClip = MovieClip(event.currentTarget);
			mc.gotoAndStop(1);
			
			switch(mc)
			{
				case m_inGameMenu.speed1X:	GlobalData.animSpeed = 1;	break;
				case m_inGameMenu.speed15X:	GlobalData.animSpeed = 1.5;	break;
				case m_inGameMenu.speed2X:	GlobalData.animSpeed = 2;	break;
			}
		}
		
		private function inGameSliderDown(event:MouseEvent):void
		{
			m_dragging = true;
			m_dragTarget = MovieClip(event.currentTarget);
			m_dragTarget.startDrag(true, m_volumeSliderRect);
		}
		
		private function inGameSliderUp(event:MouseEvent):void
		{
			if( m_dragging )
			{
				m_dragging = false;
				m_dragTarget.stopDrag();
				m_dragTarget = null;
			}
		}
		
		private function inGameMouseMove(event:MouseEvent):void
		{
			if( m_dragging )
			{
				// calculate percentage 
				var max:Number = Math.round(m_volumeSliderRect.width);
				var value:Number = Math.max(m_dragTarget.x - Math.round(m_volumeSliderRect.x), 0);
				value = Math.min(value, max);
				var percent:Number = percentage(value, max);
				
				SoundManager.getInstance().musicVolume = percent;
				
				TweenMax.killTweensOf( m_inGameMenu.musicVolume.bar );
				TweenMax.to( m_inGameMenu.musicVolume.bar, 0.5, { frame:percent * 100 } );
			}
		}
		
		private function setMenuItemState(item:MovieClip, selected:Boolean):void
		{
			if (selected)
				item.gotoAndStop(1);
			else
				item.gotoAndStop(2);
		}
		
		private function gfxSet(event:MouseEvent):void
		{
			switch(event.currentTarget)
			{
				case m_inGameMenu.gfxLow:
					setMenuItemState(m_inGameMenu.gfxLow, true);
					setMenuItemState(m_inGameMenu.gfxMed, false);
					setMenuItemState(m_inGameMenu.gfxHigh, false);
					
					m_stage.quality = StageQuality.LOW;
					ParticleManager.getInstance().enable = false;
					break;
				case m_inGameMenu.gfxMed:
					setMenuItemState(m_inGameMenu.gfxLow, false);
					setMenuItemState(m_inGameMenu.gfxMed, true);
					setMenuItemState(m_inGameMenu.gfxHigh, false);
					
					m_stage.quality = StageQuality.MEDIUM;
					ParticleManager.getInstance().enable = true;
					break;	
				case m_inGameMenu.gfxHigh:
					setMenuItemState(m_inGameMenu.gfxLow, false);
					setMenuItemState(m_inGameMenu.gfxMed, false);
					setMenuItemState(m_inGameMenu.gfxHigh, true);
					
					m_stage.quality = StageQuality.HIGH;
					ParticleManager.getInstance().enable = true;
					break;		
			}
		}
		
		private function sfxSet(event:MouseEvent):void
		{
			switch(event.currentTarget)
			{
				case m_inGameMenu.sfxOn:
						m_inGameMenu.sfxOn.gotoAndStop(1);
						m_inGameMenu.sfxOff.gotoAndStop(2);
						SoundManager.getInstance().sfxEnable = true;
						break;
				case m_inGameMenu.sfxOff:
						m_inGameMenu.sfxOn.gotoAndStop(2);
						m_inGameMenu.sfxOff.gotoAndStop(1);
						SoundManager.getInstance().sfxEnable = false;
						break;		
			}
		}
		
		private function percentage(value:Number, max:Number):Number
		{
			return (value / max);
		}
		
		static public function getInstance(): GameOptions
		{
			if( m_instance == null ){
				m_instance = new GameOptions( new SingletonLock() );
			}
			return m_instance;
		}
	}
}

class SingletonLock{}