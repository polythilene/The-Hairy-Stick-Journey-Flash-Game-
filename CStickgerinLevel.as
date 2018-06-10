package  
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	import flash.display.BlendMode;
	
	import gs.TweenMax;
	import gs.easing.Bounce;
	import gs.easing.Back;
		
	/**
	 * ...
	 * @author Kurniawan Fitriadi
	 */
	public class CStickgerinLevel extends CGameState
	{
		static public const HALF_WIDTH:int = 400;
		static public const HALF_HEIGHT:int = 225;
		static public var CAMERA:CVirtualCamera = null;
		static protected var SCROLL_SPEED:Number = 0.3;
		
		
		/* object buffers */
		private var m_virtualCamera:CVirtualCamera;
		private var m_currentActor:MovieClip;			// actor clip, for camera target
		protected var m_currentLevel:int;					// current level index
		
		protected var m_sky:MovieClip;					// sky clip
		protected var m_foreground:MovieClip;			// foreground clip
		protected var m_background:MovieClip;			// background clip
		
		protected var m_bgMaxWidth:int;					// maximum coord for camera
		protected var m_fgMaxWidth:int;					// maximum coord for camera
		
		protected var m_simulationStarted:Boolean;		// is simulation started
		protected var m_cutScene:Boolean;				// is cutscene active
		private var m_mouseX:int;						// current mouse pos
		private var m_mouseY:int;						// current mouse pos
		private var m_cameraX:int;						// current camera pos
		private var m_cameraY:int;						// current camera pos
		
		private var m_sceneContainer:MovieClip;			// scene container
		private var m_screenConverter:Point;			// converter buffer
		
		protected var m_GUI:UserInterface;
		protected var m_itemSlots:Array;				// array for item slots
		protected var m_isSlotFilled:Array;				// is this slot is filled
		protected var m_itemContainer:Array;			// array for item clip
		private var m_droppedItems:Array;				// array for dropped item
		private var m_itemToSlotIndex:Array;			// dropped item to slot index lookup
		private var m_itemPos:Array;					// array for item position
		private var m_dragging:Boolean;					// is currently dragging item
		private var m_draggedItem:MovieClip;			// dragged item
		private var m_draggedItemIndex:int;				// dragged item pocket index
		private var m_maxSlot:int;						// number of scene slots
		private var m_filledSlot:int;					// number of scene slots
		
		private var m_startTimer:Timer;						// start timer delay
		protected var m_gameOverScreen:GameOverMessage;
		protected var m_timeOutScreen:TimeOutMessage;
		private var m_paperTexture:PaperTexture;
				
		static protected var m_bgm:CSoundObject;
		
		public function CStickgerinLevel() 	{ }
		
		protected function prepareScene():void
		{
			if ( m_itemSlots.length > 0 )
			{
				for( var i:int = 0;  i < m_itemSlots.length; i++ )
				{
					var mc:MovieClip = m_itemSlots[i];
					
					mc.alpha = 0.7;
					mc.stop();
					mc.scaleX = mc.scaleY = 0.3;
					//mc.cacheAsBitmap = true;
				}
			}
			
			/*
			if( m_sky != null )
				m_sky.cacheAsBitmap = true;
			
			if( m_background != null )
				m_background.cacheAsBitmap = true;
				
			if( m_foreground != null )	
				m_foreground.cacheAsBitmap = true;
			*/	
		}
		
		override public function enter():void 
		{
			super.enter();
			
			/* create buffer */
			m_screenConverter = new Point();
			m_itemSlots = [];
			m_itemContainer = [];
			m_itemPos = [];
			m_droppedItems = [];
			m_isSlotFilled = [];
			m_itemToSlotIndex = [];
			
			/* prepare our scene */
			prepareScene();
			
			/* attach sky */
			if( m_sky != null )
				m_owner.addChild(m_sky);
			
			/* create container */
			m_sceneContainer = new MovieClip();
			m_owner.addChild(m_sceneContainer);
			m_sceneContainer.addChild(m_background);
			m_sceneContainer.addChild(m_foreground);
			
			/* attach particle renderer */
			ParticleManager.getInstance().attach(m_owner); 
			
			/* attach paper texture */
			m_paperTexture = new PaperTexture();
			m_foreground.addChild( m_paperTexture );
			m_paperTexture.blendMode = BlendMode.MULTIPLY;
			m_paperTexture.alpha = 0.65;
			m_paperTexture.width = m_paperTexture.parent.width;
			m_paperTexture.filters = [ new BlurFilter(2, 2, 3) ];
			m_paperTexture.mouseEnabled = false;
			
			/* create gui */
			m_GUI = new UserInterface();
			m_owner.addChild(m_GUI);
			m_GUI.actionPanel.startButton.gotoAndStop(1);
			m_GUI.actionPanel.startButton.buttonMode = m_GUI.actionPanel.startButton.useHandCursor = true;
			m_GUI.actionPanel.startButton.addEventListener(MouseEvent.CLICK, onStartClicked);
			
			if ( GlobalData.showYouYouWinLogo )
			{
				m_GUI.scoreCurrent.visible = false;
				m_GUI.scoreTotal.visible = false
			}
			else
			{
				m_GUI.scoreCurrent.htmlText = "SCORE: " + String(Math.max( (m_currentLevel * 2500) - (GlobalData.levelFailCount * 500), 0 ));
				m_GUI.scoreTotal.htmlText = "TOTAL SCORE: " + String(GlobalData.careerScore);
			}
			
			m_GUI.scoreCurrent.y = 	m_GUI.scoreTotal.y = -300;
			
			/* set inventory location */
			m_itemPos.push( new Point(436.9, 424.1) );
			m_itemPos.push( new Point(514.8, 424.1) );
			m_itemPos.push( new Point(594.3, 424.1) );
			m_itemPos.push( new Point(674.4, 424.1) );
			m_itemPos.push( new Point(750.8, 424.1) );
			
			/* setup inventory */
			m_maxSlot = 0;
			for (var i:int = 0; i < 5; i++)
			{
				/* create button */
				var item:InventoryItem = new InventoryItem();
				item.stop();
				item.buttonMode = item.useHandCursor = true;
				m_itemContainer.push( item );
			
				m_GUI.addChild( item );
				item.x = Point(m_itemPos[i]).x;
				item.y = Point(m_itemPos[i]).y;
				
				item.gotoAndStop(1);
				
				item.addEventListener(MouseEvent.MOUSE_MOVE, onInventoryHover);
				item.addEventListener(MouseEvent.MOUSE_OUT, onInventoryOut);
				item.addEventListener(MouseEvent.MOUSE_DOWN, onInventoryMouseDown);
				item.addEventListener(MouseEvent.MOUSE_UP, onInventoryMouseUp);
								
				/* create used item clip, the one dropped on world area */
				if( m_itemSlots[i] )
				{
					var droppedItem:MovieClip = new DroppedItem();
					droppedItem.x = MovieClip(m_itemSlots[i]).x;
					droppedItem.y = MovieClip(m_itemSlots[i]).y;
					m_foreground.addChild(droppedItem);
					droppedItem.visible = false;
					
					registerDropItemEvents(droppedItem);
					
					m_droppedItems[i] = droppedItem;
					m_maxSlot++;
				}
				item.visible = false;
			}
			
			/* create camera */
			m_virtualCamera = new CVirtualCamera();
			m_virtualCamera.width = HALF_WIDTH * 2;
			m_virtualCamera.height = HALF_HEIGHT * 2;
			m_cameraX = HALF_WIDTH;
			m_cameraY = HALF_HEIGHT;
			m_sceneContainer.addChild(m_virtualCamera);
			m_virtualCamera.setCameraTarget(m_cameraX, m_cameraY);
			CAMERA = m_virtualCamera;
			
			/* init variables */
			m_simulationStarted = false;
			m_dragging = false;
			m_GUI.alpha = 0;
			m_filledSlot = 0;
			m_startTimer = new Timer(1500);
			m_startTimer.addEventListener(TimerEvent.TIMER, startSimulation);
			
			/* register events */
			m_owner.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			
			/* arrange game buttons */
			if ( GlobalData.showWalkthroughAndMoreGames == false )
			{
				m_GUI.iconMoreGames.visible = m_GUI.iconHelp.visible = false;
				m_GUI.iconStartOver.x = 701.5;
				m_GUI.iconMenu.x = 758.5;
			}
			
			m_GUI.iconStartOver.y = -100;
			m_GUI.iconHelp.y = -100;
			m_GUI.iconMenu.y = -100;
			m_GUI.iconTime.y = -100;
			m_GUI.iconMoreGames.y = -100;
			
			m_GUI.actionPanel.y = 650;
			
			registerIconEvents(m_GUI.iconStartOver);
			registerIconEvents(m_GUI.iconHelp);
			registerIconEvents(m_GUI.iconMenu);
			registerIconEvents(m_GUI.iconMoreGames);
			
			/* setup game over screen */
			m_gameOverScreen = new GameOverMessage();
			m_gameOverScreen.gameOverRetry.useHandCursor = m_gameOverScreen.gameOverRetry.buttonMode = true;
			m_gameOverScreen.gameOverRetry.addEventListener(MouseEvent.CLICK, gameOverClick);
			m_gameOverScreen.gameOverRetry.addEventListener(MouseEvent.MOUSE_OVER, gameOverOver);
			m_gameOverScreen.gameOverRetry.addEventListener(MouseEvent.MOUSE_OUT, gameOverOut);
			m_gameOverScreen.gameOverResign.useHandCursor = m_gameOverScreen.gameOverResign.buttonMode = true;
			m_gameOverScreen.gameOverResign.addEventListener(MouseEvent.CLICK, gameOverClick);
			m_gameOverScreen.gameOverResign.addEventListener(MouseEvent.MOUSE_OVER, gameOverOver);
			m_gameOverScreen.gameOverResign.addEventListener(MouseEvent.MOUSE_OUT, gameOverOut);
			m_gameOverScreen.logo_bubbleBox.useHandCursor = m_gameOverScreen.logo_bubbleBox.buttonMode = true;
			m_gameOverScreen.logo_bubbleBox.addEventListener(MouseEvent.CLICK, gameOverClick);
			m_gameOverScreen.logo_bubbleBox.addEventListener(MouseEvent.MOUSE_OVER, gameOverOver);
			m_gameOverScreen.logo_bubbleBox.addEventListener(MouseEvent.MOUSE_OUT, gameOverOut);
			m_gameOverScreen.logo_bubbleBox.visible = GlobalData.showBubbleBoxLogo;
			
			
			/* setup time out screen */
			m_timeOutScreen = new TimeOutMessage();
			m_timeOutScreen.timeOutRetry.useHandCursor = m_timeOutScreen.timeOutRetry.buttonMode = true;
			m_timeOutScreen.timeOutRetry.addEventListener(MouseEvent.CLICK, timeOutClick);
			m_timeOutScreen.timeOutRetry.addEventListener(MouseEvent.MOUSE_OVER, timeOutOver);
			m_timeOutScreen.timeOutRetry.addEventListener(MouseEvent.MOUSE_OUT, timeOutOut);
			m_timeOutScreen.timeOutResign.useHandCursor = m_timeOutScreen.timeOutResign.buttonMode = true;
			m_timeOutScreen.timeOutResign.addEventListener(MouseEvent.CLICK, timeOutClick);
			m_timeOutScreen.timeOutResign.addEventListener(MouseEvent.MOUSE_OVER, timeOutOver);
			m_timeOutScreen.timeOutResign.addEventListener(MouseEvent.MOUSE_OUT, timeOutOut);
			m_timeOutScreen.logo_bubbleBox.useHandCursor = m_timeOutScreen.logo_bubbleBox.buttonMode = true;
			m_timeOutScreen.logo_bubbleBox.addEventListener(MouseEvent.CLICK, timeOutClick);
			m_timeOutScreen.logo_bubbleBox.addEventListener(MouseEvent.MOUSE_OVER, timeOutOver);
			m_timeOutScreen.logo_bubbleBox.addEventListener(MouseEvent.MOUSE_OUT, timeOutOut);
			m_timeOutScreen.logo_bubbleBox.visible = GlobalData.showBubbleBoxLogo;
			
			/* setup game options */
			GameOptions.getInstance().addEventListener(GameOptions.RESIGN, gameResign);
			m_owner.stage.addEventListener("Time_Critical", timeCritical);
		}
		
		override public function exit():void 
		{
			GameOptions.getInstance().removeEventListener(GameOptions.RESIGN, gameResign);
			m_owner.stage.removeEventListener("Time_Critical", timeCritical);
			
			
			TweenMax.killTweensOf(m_GUI.actionPanel.countdown);
			
			/* unregister events */
			m_GUI.actionPanel.startButton.removeEventListener(MouseEvent.CLICK, onStartClicked);
			m_owner.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			
			unregisterIconEvents(m_GUI.iconMoreGames);
			unregisterIconEvents(m_GUI.iconStartOver);
			unregisterIconEvents(m_GUI.iconHelp);
			unregisterIconEvents(m_GUI.iconMenu);
			
			/* reset inventory */
			for( var j:int; j < 5; j++ )
			{
				MovieClip(m_itemContainer[j]).removeEventListener(MouseEvent.MOUSE_MOVE, onInventoryHover);
				MovieClip(m_itemContainer[j]).removeEventListener(MouseEvent.MOUSE_OUT, onInventoryOut);
				MovieClip(m_itemContainer[j]).removeEventListener(MouseEvent.MOUSE_DOWN, onInventoryMouseDown);
				MovieClip(m_itemContainer[j]).removeEventListener(MouseEvent.MOUSE_UP, onInventoryMouseUp);
				
				if( m_droppedItems[j] )
				{
					var droppedItem:DisplayObject = DisplayObject(m_droppedItems[j]);
					unregisterDropItemEvents(droppedItem);
				}
			}
			
			/* remove and detach particle */
			ParticleManager.getInstance().clear();
			ParticleManager.getInstance().detach();
			
			/* remove texture */
			//m_owner.removeChild(m_paperTexture);
			
			if( m_paperTexture )
				m_foreground.removeChild(m_paperTexture);
			
			
			/* remove scene */
			m_owner.removeChild(m_GUI);
			
			if( m_sky != null )
				m_owner.removeChild(m_sky);
				
			m_sceneContainer.removeChild(m_background);
			m_sceneContainer.removeChild(m_foreground);
			m_sceneContainer.removeChild(m_virtualCamera);
			m_owner.removeChild(m_sceneContainer);
			
			/* remove objects */
			m_sky = null;
			m_background = null;
			m_foreground = null;
			m_sceneContainer = null;
			m_virtualCamera = null;
			m_GUI = null;
			m_currentActor = null;
			CAMERA = null;
		}
		
		private function gameResign(event:Event):void
		{
			stopAnimation(m_currentActor);
			m_bgm.stop();
			m_bgm = null;
		}
		
		/* track mouse coordinate */
		private function onMouseMove(event:MouseEvent):void
		{
			m_mouseX = event.stageX;
			m_mouseY = event.stageY;
		}
		
		/* gui icon events */
		private function registerIconEvents(icon:MovieClip):void
		{
			icon.mouseChildren = false;
			icon.useHandCursor = icon.buttonMode = true;
			//icon.cacheAsBitmap = true;
			
			icon.addEventListener(MouseEvent.MOUSE_OVER, onIconOver);
			icon.addEventListener(MouseEvent.MOUSE_OUT, onIconOut);
			icon.addEventListener(MouseEvent.CLICK, onIconClick);
		}
		
		private function unregisterIconEvents(icon:MovieClip):void
		{
			icon.removeEventListener(MouseEvent.MOUSE_OVER, onIconOver);
			icon.removeEventListener(MouseEvent.MOUSE_OUT, onIconOut);
			icon.removeEventListener(MouseEvent.CLICK, onIconClick);
		}
		
		private function onIconOver(event:MouseEvent):void
		{
			SoundManager.getInstance().playSFX("SFX_Button04");
			var mc:MovieClip = MovieClip(event.currentTarget);
			TweenMax.to(mc, 0.5, {glowFilter:{color:0xffff00, alpha:1, blurX:10, blurY:10, strength:2}});
			mc.icon.gotoAndPlay(2);
		}
		
		private function onIconOut(event:MouseEvent):void
		{
			var mc:MovieClip = MovieClip(event.currentTarget);
			TweenMax.to(mc, 0.5, {glowFilter:{color:0xffff00, alpha:0, blurX:0, blurY:0, strength:0}});
			mc.icon.gotoAndStop(1);
		}
		
		private function onIconClick(event:MouseEvent):void
		{
			SoundManager.getInstance().playSFX("SFX_Button03");
			var mc:MovieClip = MovieClip(event.currentTarget);
			TweenMax.to(mc, 0.5, {glowFilter:{color:0xffff00, alpha:0, blurX:0, blurY:0, strength:0}});
			mc.icon.gotoAndStop(1);
			
			if ( mc == m_GUI.iconStartOver )
			{
				stopAnimation(m_currentActor);
				GameStateManager.getInstance().restart();
			}
			else if ( mc == m_GUI.iconMenu )
			{
				GameOptions.getInstance().toggleResignButton(true);
				GameOptions.getInstance().show(m_owner.stage);
			}
			else if ( mc == m_GUI.iconHelp )
			{
				navigateTo("http://www.bubblebox.com/clickreg.php?type=gamestats&id=1823&subid=walkthrough&action=walkthrough_1823");
			}
			else if ( mc == m_GUI.iconMoreGames )
			{
				navigateTo("http://www.bubblebox.com/clickreg.php?type=gamestats&id=1823&subid=ingame");
			}
		}
		
		/* our main update */
		override public function update(elapsedTime:int):void 
		{
			if( m_dragging && m_draggedItem )
			{
				m_draggedItem.x = m_mouseX;
				m_draggedItem.y = m_mouseY;
			}
			
			if( !m_simulationStarted && !m_cutScene && m_mouseY > 80 && m_mouseY < 390)
			{
				if( m_mouseX < 100 && m_cameraX > HALF_WIDTH )
				{
					m_cameraX -= SCROLL_SPEED * elapsedTime;
					m_cameraX = Math.max(HALF_WIDTH, m_cameraX);
				}
				else if( m_mouseX > 700 && m_cameraX < m_fgMaxWidth-HALF_WIDTH )
				{
					m_cameraX += SCROLL_SPEED * elapsedTime;
					m_cameraX = Math.min(m_fgMaxWidth - HALF_WIDTH, m_cameraX);
				}
				
				m_virtualCamera.setCameraTarget( m_cameraX, m_cameraY );
			}
			
			var fg_length:int = (m_fgMaxWidth - HALF_WIDTH) - HALF_WIDTH;
			var fg_curr:int = m_cameraX - HALF_WIDTH;
			var percent:Number = fg_curr / fg_length;
			var bg_length:int = (m_bgMaxWidth - HALF_WIDTH) - HALF_WIDTH;
			var bg_curr:int = bg_length * percent;
			m_background.x = bg_curr;
			
			ParticleManager.getInstance().update(elapsedTime);
		}
		
		protected function prepareActor(actor:MovieClip):void
		{
			prepareAnimation(actor);
			//actor.cacheAsBitmap = true;
			actor.visible = false;
		}
		
		protected function setActor(newActor:MovieClip, cameraPos:int=0):void
		{
			if( m_currentActor )
			{
				m_currentActor.stop();
				m_currentActor.visible = false;
			}
			
			newActor.visible = true;
			newActor.gotoAndPlay(1);
			
			playAnimation(newActor);
			m_currentActor = newActor;
			
			if ( GlobalData.animSpeed > 1 )
			{
				var animTime:Number = newActor.totalFrames / 30 / GlobalData.animSpeed;
				TweenMax.to( newActor, animTime, { frame:newActor.totalFrames } );
			}
			
			// set camera
			if ( m_simulationStarted )
			{
				var rect:Rectangle = m_currentActor.getBounds(m_currentActor.parent);
				var newTargetX:int = rect.x + (rect.width >> 1);
				
				if ( cameraPos != 0 )
				{
					newTargetX = cameraPos;
				}
				else 
				{
					if( newTargetX < HALF_WIDTH )
						newTargetX = HALF_WIDTH;
					else if( newTargetX > m_fgMaxWidth - HALF_WIDTH )
						newTargetX = m_fgMaxWidth - HALF_WIDTH;
				}
					
				TweenMax.killTweensOf( m_virtualCamera );
				TweenMax.to( m_virtualCamera, 1.5, { x:newTargetX, onUpdate:function():void 
																 { 
																	m_cameraX = m_virtualCamera.x; 
																 } } );
			}
		}
		
		protected function cameraInvalidate():void
		{
			// set camera
			var rect:Rectangle = m_currentActor.getBounds(m_currentActor.parent);
			var newTargetX:int = rect.x + (rect.width >> 1);
				
			if( newTargetX < HALF_WIDTH )
				newTargetX = HALF_WIDTH;
			else if( newTargetX > m_fgMaxWidth - HALF_WIDTH )
				newTargetX = m_fgMaxWidth - HALF_WIDTH;
				
			TweenMax.killTweensOf( m_virtualCamera );
			TweenMax.to( m_virtualCamera, 1, { x:newTargetX, onUpdate:function():void 
															 { 
																m_cameraX = m_virtualCamera.x; 
															 } } );
		}
		
		protected function getInventoryIndex(clip:MovieClip):int
		{
			var index:int = 0;
			var found:Boolean = false;
			while (!found && index < 5)
			{
				found = (m_itemContainer[index] == clip) ? true : false;
				if( !found ) index++;
			}
			return index;
		}
		
		protected function getSlotItemToInventoryIndex(slotItem:MovieClip):int
		{
			var index:int = 0;
			var found:Boolean = false;
			while (!found && index < 5)
			{
				found = (MovieClip(m_itemContainer[index]).currentFrame == slotItem.currentFrame) ? true : false;
				if( !found ) index++;
			}
			return index;
		}
		
		private function resetSlotState():void
		{
			for( var i:int = 0; i < m_itemSlots.length; i++ )
			{
				var mc:MovieClip = m_itemSlots[i];
				TweenMax.to( mc, 1.0, { alpha:0.7, scaleX:0.3, scaleY:0.3 } );	
			}
		}
		
		private function onInventoryHover(event:MouseEvent):void
		{
			var mc:MovieClip = MovieClip(event.currentTarget);
			if( mc.currentFrame > 1 )
				TweenMax.to(mc, 1, { glowFilter: { color:0xFFCC00, alpha:1, blurX:15, blurY:15, strength:2.5 }} );
				
			if ( m_dragging )
			{
				mc = testDropSlot(m_mouseX, m_mouseY);
				if( mc != null )
				{
					TweenMax.to( mc, 1.0, { alpha:0.9, scaleX:0.5, scaleY:0.5 } );
				}
				else
				{
					resetSlotState();
				}
			}
		}
		
		private function onInventoryOut(event:MouseEvent):void
		{
			var mc:MovieClip = MovieClip(event.currentTarget);
			if( mc.currentFrame > 1 )
				TweenMax.to(mc, 1, {glowFilter:{color:0xFFCC00, blurX:0, blurY:0, strength:0}});
		}	
		
		private function onInventoryMouseDown(event:MouseEvent):void
		{
			var mc:MovieClip = MovieClip(event.currentTarget);
			if ( !m_cutScene && mc.currentFrame != 1 )
			{
				m_dragging = true;
				m_draggedItem = mc;
				m_draggedItemIndex = getInventoryIndex(mc);
				TweenMax.to(m_draggedItem, 1, { scaleX:2.5, scaleY:2.5, ease:Bounce.easeOut } );
			}
			resetSlotState();
		}
		
		private function onInventoryMouseUp(event:MouseEvent):void
		{
			if ( m_dragging )
			{
				m_dragging = false;
				dropItem();
			}
			resetSlotState();
		}
		
		protected function getSlotIndex(slot:MovieClip):int
		{
			var index:int = 0;
			var slotTemp:MovieClip = m_itemSlots[index];
			var found:Boolean = false;
			
			while( !found && slotTemp && index < 5 )
			{
				if ( slot == slotTemp )
				{
					found = true;
				}
				else 
				{
					index++;
					slotTemp = m_itemSlots[index];
				}
			}
			return index;
		}
		
		protected function testDropSlot(screenCoordX:int, screenCoordY:int):MovieClip
		{
			/* calculate world coordinate */
			var dropLocation:Point = screenToWorld(screenCoordX, screenCoordY);
			
			/* test collision with item slots */
			var index:int = 0;
			var collide:Boolean = false;
			var slot:MovieClip = m_itemSlots[index];
			
			var slotHalfWidth:int = slot.width >> 1;
			var slotHalfHeight:int = slot.height >> 1;
			
			while( slot && !collide && index < 5 )
			{
				if ( isPointInsideBox( dropLocation.x, dropLocation.y, 
										slot.x - slotHalfWidth, slot.y - slotHalfHeight,
										slot.width, slot.height ) )
				{
					collide = true;
				}
				else
				{
					index++;
					slot = m_itemSlots[index];
				}
			}

			return (collide) ? slot : null;
		}
		
		protected function dropItem():void
		{
			// do some action
			var slot:MovieClip = testDropSlot(m_draggedItem.x, m_draggedItem.y);
			
			if( slot != null )
				var index:int = getSlotIndex(slot);
			
			if ( slot && !m_isSlotFilled[index] )
			{
				// show drop item & hide selected inventory
				MovieClip(m_droppedItems[index]).gotoAndStop(m_draggedItem.currentFrame);
				MovieClip(m_droppedItems[index]).visible = true;
				
				m_draggedItem.visible = false;
				m_isSlotFilled[index] = true;
				m_itemToSlotIndex[getInventoryIndex(m_draggedItem)] = index;
				
				m_filledSlot++;
			}
			else
			{
				// return item to pocket
				var retX:int = Point(m_itemPos[m_draggedItemIndex]).x;
				var retY:int = Point(m_itemPos[m_draggedItemIndex]).y;
				
				TweenMax.to( m_draggedItem, 0.5, { scaleX:1, scaleY:1, x:retX, y:retY } );
			}
			m_draggedItem = null;
		}
		
		protected function get mouseX():int
		{
			return m_mouseX;
		}
		
		protected function get mouseY():int
		{
			return m_mouseY;
		}
		
		protected function screenToWorld(x:int, y:int):Point
		{
			m_screenConverter.x = m_virtualCamera.x - HALF_WIDTH + x;
			m_screenConverter.y = m_virtualCamera.y - HALF_HEIGHT + y;
			
			return m_screenConverter;
		}
		
		protected function worldToScreen(x:int, y:int):Point
		{
			m_screenConverter.x = HALF_WIDTH - m_virtualCamera.x + x;
			m_screenConverter.y = HALF_HEIGHT - m_virtualCamera.y + y;
			
			return m_screenConverter;
		}
		
		protected function isPointInsideBox( point_x:int, point_y:int,
											 box_x:int, box_y:int,
											 box_width:int, box_height:int) : Boolean
		{
			if( point_x < box_x ) 
				return false;
			if( point_x > box_x+box_width )
				return false;
			if( point_y < box_y ) 
				return false;
			if( point_y > box_y+box_height ) 
				return false;

			return true;
		}
		
		private function onStartClicked(event:MouseEvent):void
		{
			var mc:MovieClip = MovieClip(event.currentTarget);
			mc.gotoAndPlay(2);
			
			if ( m_maxSlot == m_filledSlot && !m_simulationStarted )
			{
				m_simulationStarted = true;
				startButtonClicked();
			}
			else
			{
				SoundManager.getInstance().playSFX("SFX_Button02");
			}
		}
		
		protected function checkSlotItem(slotIndex:int):int
		{
			return MovieClip(m_droppedItems[slotIndex]).currentFrame;
		}
		
		protected function hideSlotItem(slotIndex:int):void
		{
			MovieClip(m_droppedItems[slotIndex]).gotoAndStop(1);
		}
		
		protected function startButtonClicked():void
		{
			TweenMax.killTweensOf(m_GUI.actionPanel.countdown);		//stop time
			
			TweenMax.to( m_GUI.actionPanel, 1, { y:500, onComplete:function():void 
														{
															TweenMax.to( m_GUI.scoreCurrent, 1.5, { y:404, ease:Bounce.easeOut } );
															TweenMax.to( m_GUI.scoreTotal, 1, { y:421, ease:Bounce.easeOut } );
														}
												} );
												
			// hide unused items
			for (var i:int; i < m_itemContainer.length; i++)
			{
				var mc:MovieClip = m_itemContainer[i];
				mc.visible = false;
			}
			
			cameraInvalidate();
			m_startTimer.start();
		}
		
		protected function startSimulation(event:TimerEvent):void
		{
			m_startTimer.removeEventListener(TimerEvent.TIMER, startSimulation);
		}
		
		private function stopAnimation(animClip:MovieClip):void
		{
			if ( animClip.numChildren > 0 )
			{
				for ( var i:int = 0; i < animClip.numChildren; i++ )
				{
					if ( animClip.getChildAt(i) is MovieClip )
					{
						var mc:MovieClip = MovieClip(animClip.getChildAt(i));
						stopAnimation(mc);
					}
				}
			}
			animClip.stop();
		}
		
		private function prepareAnimation(animClip:MovieClip):void
		{
			if ( animClip.numChildren > 0 )
			{
				for ( var i:int = 0; i < animClip.numChildren; i++ )
				{
					if ( animClip.getChildAt(i) is MovieClip )
					{
						var mc:MovieClip = MovieClip(animClip.getChildAt(i));
						stopAnimation(mc);
					}
				}
			}
			animClip.stop();
			animClip.gotoAndStop(1);
		}
		
		private function registerDropItemEvents(item:MovieClip):void
		{
			//item.cacheAsBitmap = true;
			item.buttonMode = item.useHandCursor = true;
			item.addEventListener(MouseEvent.CLICK, droppedItemClicked);
		}
		
		private function unregisterDropItemEvents(item:DisplayObject):void
		{
			item.removeEventListener(MouseEvent.CLICK, droppedItemClicked);
		}
		
		private function droppedItemClicked(event:MouseEvent):void
		{
			/* return dropped item to inventory */
			
			
			if ( !m_simulationStarted )
			{
				var index:int = 0;
				var found:Boolean = false;
				var mc:MovieClip = MovieClip(event.currentTarget);
				
				while ( !found && index < 5 )
				{
					if ( mc == m_droppedItems[index] )
					{
						found = true;
					}
					else
					{
						index++;
					}
				}
				
				/* do some action */
				if ( found )
				{
					var slotMC:MovieClip = MovieClip(m_itemSlots[index]);
					var inventory:MovieClip = MovieClip(m_itemContainer[ getSlotItemToInventoryIndex(mc) ]);
					
					var pos:Point = worldToScreen(slotMC.x, slotMC.y);
					
					inventory.x = pos.x;
					inventory.y = pos.y;
					inventory.scaleX = 2.5;
					inventory.scaleY = 2.5;
					inventory.gotoAndStop( mc.currentFrame );
					inventory.visible = true;
					mc.visible = false;
					
					/* return item to pocket */
					var retX:int = Point(m_itemPos[getInventoryIndex(inventory)]).x;
					var retY:int = Point(m_itemPos[getInventoryIndex(inventory)]).y;
					
					/* clear array state */
					m_isSlotFilled[m_itemToSlotIndex[getInventoryIndex(inventory)]] = false;
					m_itemToSlotIndex[getInventoryIndex(inventory)] = -1;
					
					m_filledSlot--;
					
					TweenMax.to( inventory, 0.5, { scaleX:1, scaleY:1, x:retX, y:retY } );
				}
				
				m_draggedItem = null;
			}
		}
		
		private function playAnimation(animClip:MovieClip):void
		{
			if ( animClip.numChildren > 0 )
			{
				for ( var i:int = 0; i < animClip.numChildren; i++ )
				{
					if ( animClip.getChildAt(i) is MovieClip )
					{
						var mc:MovieClip = MovieClip( animClip.getChildAt(i) );
						playAnimation(mc);
					}
				}
			}
			animClip.play();
		}
		
		protected function simulationComplete():void
		{
			TweenMax.killTweensOf( m_GUI.actionPanel.countdown );
			
			/* FLAWLESS ACHIEMENT */
			if ( GlobalData.levelFailCount == 0 )
			{
				if ( !GlobalData.achievementFlawless )
				{
					GlobalData.achievementFlawless = true;
					achievementMessage(	GlobalData.achievementString["flawless"][0],
										GlobalData.achievementString["flawless"][1] );
									
					unlockNewgroundsMedal("Flawless");					
				}
			}
			
			var buffPoint:int = Math.max( GlobalData.careerScore + (m_currentLevel * 2500) - (GlobalData.levelFailCount * 500), 0 );
			GlobalData.careerScore = buffPoint;
			GlobalData.levelFailCount = 0;
			
			trace("=============================COMPLETED==============================");
			trace("Total Score:", GlobalData.careerScore);
			
			stopAnimation(m_currentActor);
			
			/* save data */
			Serializer.getInstance().saveData();
		}
		
		protected function gameOver(isHarryDead:Boolean = false, timeout:Boolean = false):void
		{
			TweenMax.killTweensOf( m_GUI.actionPanel.countdown );
			GlobalData.levelFailCount++;
			
			m_foreground.removeChild( m_paperTexture );
			m_paperTexture = null;
			
			var buffPoint:int = Math.max( (m_currentLevel * 2500) - (GlobalData.levelFailCount * 500), 0 );
			trace("=============================GAME OVER==============================");
			trace("Remaining Point:", buffPoint);
			
			stopAnimation(m_currentActor);
			
			
			if( isHarryDead )
			{
				/* FIRST BLOOD ACHIEVEMENT */
				if ( !GlobalData.achievementFirstBlood )
				{
					GlobalData.achievementFirstBlood = true;
					achievementMessage(	GlobalData.achievementString["firstBlood"][0],
										GlobalData.achievementString["firstBlood"][1] );
					unlockNewgroundsMedal("First Blood");		
				}
				
				
				
				
				/* I SEE DEAD STICK ACHIEVEMENT */
				if ( !GlobalData.achievementISeeDeadStick )
				{
					GlobalData.achievementISeeDeadStickCounter++;
					
					if( GlobalData.achievementISeeDeadStickCounter >= 3 )
					{
						GlobalData.achievementISeeDeadStick = true;
						achievementMessage(	GlobalData.achievementString["iSeeDeadStick"][0],
											GlobalData.achievementString["iSeeDeadStick"][1] );
											
						unlockNewgroundsMedal("Dead Stick");
					}
				}
			}
			
			if( m_sky )
				TweenMax.to(m_sky, 2, { blurFilter: { blurX:8, blurY:8 }} );
				
			TweenMax.to(m_background, 2, { blurFilter: { blurX:8, blurY:8 }} );
			TweenMax.to(m_foreground, 2, { blurFilter: { blurX:8, blurY:8 }} );
			
			
			if ( timeout )
			{
				m_owner.addChild(m_timeOutScreen);
				m_timeOutScreen.alpha = 0;
				m_timeOutScreen.watch.gotoAndPlay(2);
				TweenMax.to(m_timeOutScreen, 1, { alpha:1 } );
			}
			else
			{
				m_owner.addChild(m_gameOverScreen);
				m_gameOverScreen.x = 415.6;
				m_gameOverScreen.y = 226.3;
				m_gameOverScreen.alpha = 0;
				TweenMax.to(m_gameOverScreen, 2, { alpha:1 } );
			}
			
			InGameCredits.getInstance().detach();
			ParticleManager.getInstance().detach();
			
			m_GUI.visible = false;
		}
		
		protected function showGUI():void
		{
			TweenMax.to( m_GUI, 0.7, { alpha:1 } );
			
			TweenMax.to( m_GUI.iconStartOver, randomRange(1, 3), { y:46.9, ease:Bounce.easeOut } );
			TweenMax.to( m_GUI.iconHelp, randomRange(1, 3), { y:46.5, ease:Bounce.easeOut } );
			TweenMax.to( m_GUI.iconMenu, randomRange(1, 3), { y:48, ease:Bounce.easeOut } );
			TweenMax.to( m_GUI.iconTime, randomRange(1, 3), { y:46.9, ease:Bounce.easeOut } );
			TweenMax.to( m_GUI.iconMoreGames, randomRange(1, 3), { y:46.9, ease:Bounce.easeOut } );
			
			TweenMax.to( m_GUI.scoreCurrent, randomRange(1, 2), { y:361.8, ease:Bounce.easeOut } );
			TweenMax.to( m_GUI.scoreTotal, randomRange(1, 2), { y:378.8, ease:Bounce.easeOut } );
			
			
			TweenMax.to( m_GUI.actionPanel, 1.5, { y:424.8, onComplete:function():void
													{
														for(var i:int = 0; i < 5; i++)
														{
															var mc:MovieClip = MovieClip(m_itemContainer[i]);
															mc.scaleX = mc.scaleY = 2.5;
															mc.alpha = 0;
															mc.visible = true;
															
															TweenMax.to( mc, 2 + i, { alpha:1, scaleX:1, scaleY:1, ease:Bounce.easeOut } );
														}
													}
												} );
												
			for ( var i:int = 0; i < 5; i++ )
			{
				var mc:MovieClip = m_itemContainer[i];
				mc.useHandCursor = mc.buttonMode = (mc.currentFrame > 1) ? true : false;
			}
		}
		
		/* serializer methods */
		protected function setLevelAccess(level_id:int):void
		{
			GlobalData.levelAccess[level_id - 1] = true;
			Serializer.getInstance().saveData();
		}
		
		/* countdown time */
		protected function setCountdown(time:int):void
		{
			m_GUI.actionPanel.countdown.gotoAndStop(1);
			TweenMax.to(m_GUI.actionPanel.countdown, time, { frame:200, onComplete:function():void { gameOver(false, true);  } } );
		}
		
		private function unregisterButtons():void
		{
			m_gameOverScreen.gameOverRetry.removeEventListener(MouseEvent.CLICK, gameOverClick);
			m_gameOverScreen.gameOverRetry.removeEventListener(MouseEvent.MOUSE_OVER, gameOverOver);
			m_gameOverScreen.gameOverRetry.removeEventListener(MouseEvent.MOUSE_OUT, gameOverOut);
			
			m_gameOverScreen.gameOverResign.removeEventListener(MouseEvent.CLICK, gameOverClick);
			m_gameOverScreen.gameOverResign.removeEventListener(MouseEvent.MOUSE_OVER, gameOverOver);
			m_gameOverScreen.gameOverResign.removeEventListener(MouseEvent.MOUSE_OUT, gameOverOut);
			
			m_gameOverScreen.logo_bubbleBox.removeEventListener(MouseEvent.CLICK, gameOverClick);
			m_gameOverScreen.logo_bubbleBox.removeEventListener(MouseEvent.MOUSE_OVER, gameOverOver);
			m_gameOverScreen.logo_bubbleBox.removeEventListener(MouseEvent.MOUSE_OUT, gameOverOut);
		}
			
		private function gameOverClick(event:MouseEvent):void
		{
			SoundManager.getInstance().playSFX("SFX_Button03");
			
			if ( event.currentTarget == m_gameOverScreen.gameOverRetry )
			{
				m_owner.removeChild(m_gameOverScreen);
				unregisterButtons();
				
				GameStateManager.getInstance().restart();
				
			}
			else if ( event.currentTarget == m_gameOverScreen.gameOverResign )
			{
				m_owner.removeChild(m_gameOverScreen);
				unregisterButtons();
				
				if( m_bgm )
					m_bgm.stop();
					
				m_bgm = null;	
					
				GameStateManager.getInstance().setState( GameState_GameMenu.getInstance() );
			}
			else if (event.currentTarget == m_gameOverScreen.logo_bubbleBox )
			{
				navigateTo("http://www.bubblebox.com/clickreg.php?type=gamestats&id=1823&subid=gameover");
			}
		}
		
		private function gameOverOver(event:MouseEvent):void
		{
			SoundManager.getInstance().playSFX("SFX_Button04");
			
			if( event.currentTarget != m_gameOverScreen.logo_bubbleBox )
				MovieClip(event.currentTarget).scaleX = MovieClip(event.currentTarget).scaleY = 1.2;
		}
		
		private function gameOverOut(event:MouseEvent):void
		{
			if( event.currentTarget != m_gameOverScreen.logo_bubbleBox )
				MovieClip(event.currentTarget).scaleX = MovieClip(event.currentTarget).scaleY = 1.0;
		}
		
		private function timeOutOver(event:MouseEvent):void
		{
			SoundManager.getInstance().playSFX("SFX_Button04");
			
			if( event.currentTarget != m_timeOutScreen.logo_bubbleBox )
				MovieClip(event.currentTarget).scaleX = MovieClip(event.currentTarget).scaleY = 1.2;
		}
		
		private function timeOutOut(event:MouseEvent):void
		{
			if( event.currentTarget != m_timeOutScreen.logo_bubbleBox )
				MovieClip(event.currentTarget).scaleX = MovieClip(event.currentTarget).scaleY = 1.0;
		}
		
		private function timeOutClick(event:MouseEvent):void
		{
			SoundManager.getInstance().playSFX("SFX_Button03");
			
			if ( event.currentTarget == m_timeOutScreen.timeOutRetry )
			{
				m_owner.removeChild(m_timeOutScreen);
				unregisterButtons();
				
				GameStateManager.getInstance().restart();
				
			}
			else if ( event.currentTarget == m_timeOutScreen.timeOutResign )
			{
				m_owner.removeChild(m_timeOutScreen);
				unregisterButtons();
				
				if( m_bgm )
					m_bgm.stop();
					
				m_bgm = null;
					
				GameStateManager.getInstance().setState( GameState_GameMenu.getInstance() );
			}
			else if ( event.currentTarget == m_timeOutScreen.logo_bubbleBox )
			{
				navigateTo("http://www.bubblebox.com/clickreg.php?type=gamestats&id=1823&subid=timeout");
			}
		}
		
		private function timeCritical(event:Event):void
		{
			SoundManager.getInstance().playSFX("SFX_Button02");
			m_GUI.iconTime.gotoAndStop(2);
		}
	}
}