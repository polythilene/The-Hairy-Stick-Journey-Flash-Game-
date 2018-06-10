package 
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.utils.getDefinitionByName;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.events.*;
	
	import gs.TweenMax;
	import CPMStar.*;
	import flash.system.Capabilities;
	
	
	//------- START NG API-------
	import NewgroundsAPI;
	import flash.net.URLRequest;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.system.Security;
	import flash.net.URLLoader;
	import com.newgrounds.API;
	//------- END NG API--------
	
	/**
	 * ...
	 * @author Wiwit
	 */
	public class Preloader extends MovieClip 
	{
		private var m_preloaderScreen:PreloaderScreen;
		private var m_player10Required:Flash10Required;
		private var m_screenLock:SiteLockMessage;
		private var m_adLoaded:Boolean = false;
		
		import NewgroundsAPI;
		
		public function Preloader() 
		{
			if ( getPlayerMajorVersionNumber() < 10 )
			{
				m_player10Required = new Flash10Required();
				addChild(m_player10Required);
				m_player10Required.flashLink.dummy.alpha = 0;
				m_player10Required.flashLink.buttonMode = m_player10Required.flashLink.useHandCursor = true;
				m_player10Required.flashLink.addEventListener(MouseEvent.CLICK, flashLinkClicked);
			}
			//else if( GlobalData.siteLock && !siteLockTest(GlobalData.siteLockURL) )
			else if( GlobalData.siteLock && !siteLockFilter() )
			{
				m_screenLock = new SiteLockMessage();
				addChild(m_screenLock);
				
				registerButtonEvent( m_screenLock.flashLink );
				
				m_screenLock.bubbleboxlogo.visible = GlobalData.showBubbleBoxLogo;
				m_screenLock.bgsLogo.visible = GlobalData.showBelugerinLogo;
				m_screenLock.andkonlogo.visible = GlobalData.showAndkonLogo;
				m_screenLock.armorLogo.visible = GlobalData.showArmorGamesLogo;
				
				if( GlobalData.showBubbleBoxLogo )
					registerButtonEvent( m_screenLock.bubbleboxlogo );
				
				if( GlobalData.showBelugerinLogo )
					registerButtonEvent( m_screenLock.bgsLogo );
				
				if( GlobalData.showAndkonLogo )
					registerButtonEvent( m_screenLock.andkonlogo );
					
				if( GlobalData.showArmorGamesLogo )
					registerButtonEvent( m_screenLock.armorLogo );	
			}
			else
			{
				if ( GlobalData.showAd == false || GlobalData.adType != GlobalData.AD_YOUYOUWIN )
				{
					trace("Creating default preloader");
					addEventListener(Event.ENTER_FRAME, checkFrame);
					loaderInfo.addEventListener(ProgressEvent.PROGRESS, progress);
				
					// show loader
					m_preloaderScreen = new PreloaderScreen();
					m_preloaderScreen.startButton.visible = false;
					m_preloaderScreen.startButton.alpha = 0;
					m_preloaderScreen.startButton.buttonMode = m_preloaderScreen.startButton.useHandCursor = true;
					m_preloaderScreen.startButton.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
					m_preloaderScreen.startButton.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
					m_preloaderScreen.cpmContainer.visible = false;
					m_preloaderScreen.ngTank.visible = false;
					
					m_preloaderScreen.logoBelugerin.visible = GlobalData.showBelugerinLogo;
					m_preloaderScreen.logoBubbleBox.visible = GlobalData.showBubbleBoxLogo;
					m_preloaderScreen.logoAndkon.visible = GlobalData.showAndkonLogo;
					m_preloaderScreen.armorLogo.visible = GlobalData.showArmorGamesLogo;
					
					
					if( GlobalData.showBelugerinLogo )	registerButtonEvent( m_preloaderScreen.logoBelugerin );
					if( GlobalData.showBubbleBoxLogo )	registerButtonEvent( m_preloaderScreen.logoBubbleBox );
					if( GlobalData.showAndkonLogo )		registerButtonEvent( m_preloaderScreen.logoAndkon );
					if( GlobalData.showArmorGamesLogo ) registerButtonEvent( m_preloaderScreen.armorLogo );
						
					registerButtonEvent(m_preloaderScreen.logoBelugerin);
					addChild(m_preloaderScreen);
				}
				
				// CPM Star
				if ( GlobalData.showAd )
				{
					switch( GlobalData.adType )
					{
						case GlobalData.AD_CPMSTAR:
							m_preloaderScreen.cpmContainer.visible = true;
							var CPMStarContentSpotID:String = "2404QBCF1B64B";
							var ad:DisplayObject = new CPMStar.AdLoader(CPMStarContentSpotID);
							m_preloaderScreen.cpmContainer.addChild(ad);
							break;
						case GlobalData.AD_NEWGROUNDS:
							m_preloaderScreen.cpmContainer.visible = true;
							m_preloaderScreen.ngTank.visible = true;
							
							Security.allowDomain("70.87.128.99");
							Security.allowInsecureDomain("70.87.128.99");
							Security.allowDomain("ads.shizmoo.com");
							Security.allowInsecureDomain("ads.shizmoo.com");
							Security.allowDomain("www.cpmstar.com");
							Security.allowInsecureDomain("www.cpmstar.com");
							Security.allowDomain("server.cpmstar.com");
							Security.allowInsecureDomain("server.cpmstar.com");
							
							if( NewgroundsAPI.getAdURL() ) 
							{
								startAd( NewgroundsAPI.getAdURL() );
							}		
							
							NewgroundsAPI.addEventListener(NewgroundsAPI.ADS_APPROVED, startAd);
							m_preloaderScreen.ngTank.ng_adObject.NG_Button.addEventListener(MouseEvent.CLICK, loadNGSite);
							
							NewgroundsAPI.linkAPI(this);
							NewgroundsAPI.connectMovie(12758);
							break;
						case GlobalData.AD_YOUYOUWIN:
							FWAd_AS3.showAd({
												container:this,					//ads container
												x:0,							// Ad Position x
												y:0,							// Ad Position y
												wid:800,						// Ad width
												hei:450,						// Ad height
												id:"Belugerin-HarryStick-1",	// Ads id
												//id:"Belugerin-MassiveWar-1",
												adType:"loading",				// Ads when loading
												
												onClickStartBtn:youyou_start
											});
							break;

					}
				}
				
				if ( GlobalData.newgroundsAPI )
				{
					API.connect(loaderInfo, "12758", "MK47ivWoTzvjZE2CvQ6oY3ePvv7WlSmk");
				}
			}
		}
		
		private function youyou_start():void
		{
			//_root.play();
			trace("======= START PLAY ======");
			
			stop();
			var mainClass:Class = getDefinitionByName("Main") as Class;
			addChild(new mainClass() as DisplayObject);
		}
		
		private function flashLinkClicked(event:MouseEvent):void
		{
			navigateTo("http://get.adobe.com/flashplayer/");
		}
		
		private function progress(e:ProgressEvent):void 
		{
			// update loader
			var perc:Number = e.bytesLoaded / e.bytesTotal * 100;
			m_preloaderScreen.progressBar.progressText.htmlText = String(Math.floor(perc)) + "%";
			
			var framePos:int = perc / 100 * m_preloaderScreen.progressBar.bar.totalFrames;
			TweenMax.killTweensOf( m_preloaderScreen.progressBar.bar );
			TweenMax.to( m_preloaderScreen.progressBar.bar, 0.5, {frame:framePos } );
		}
		
		private function registerButtonEvent(mc:MovieClip):void
		{
			mc.buttonMode = mc.useHandCursor = true;
			mc.addEventListener(MouseEvent.CLICK, onButtonClick);
		}
		
		private function unregisterButtonEvent(mc:MovieClip):void
		{
			mc.removeEventListener(MouseEvent.CLICK, onButtonClick);
		}
		
		private function onButtonClick(event:MouseEvent):void
		{
			var mc:MovieClip = MovieClip(event.currentTarget);
			
			
			if ( m_screenLock != null && mc == m_screenLock.bubbleboxlogo )
			{
				navigateTo("http://www.bubblebox.com/clickreg.php?type=gamestats&id=1823&subid=sitelock");
			}
			else if (  m_screenLock != null && mc == m_screenLock.flashLink )
			{
				navigateTo(GlobalData.siteLockTrackbackURL);
				/*
				if( GlobalData.showAndkonLogo )
					navigateTo("http://www.andkon.com/arcade/");						// lock to andkon
				else
					navigateTo("http://www.bubblebox.com/play/adventure/1823.htm");		// lock to bubble
				*/	
				
			}
			else if (  m_screenLock != null && mc == m_screenLock.andkonlogo )
			{
				navigateTo("http://www.andkon.com/arcade/");							// lock to andkon
			}	
			else if (  m_screenLock != null && mc == m_screenLock.armorLogo )
			{
				navigateTo("http://www.armorgames.com/");							// lock to armorgames
			}	
			else if ( m_screenLock != null && mc ==  m_screenLock.bgsLogo )
			{
				//navigateTo("http://www.bubblebox.com/clickreg.php?type=gamestats&id=1823&subid=preloader");
				navigateTo("http://www.belugerinstudios.com");
			}
			else if( m_preloaderScreen != null && mc == m_preloaderScreen.logoBubbleBox )
			{
				navigateTo("http://www.bubblebox.com/clickreg.php?type=gamestats&id=1823&subid=preloader");
			}
			else if( m_preloaderScreen != null && mc == m_preloaderScreen.logoBelugerin )
			{
				navigateTo("http://www.belugerinstudios.com");
			}
			else if( m_preloaderScreen != null && mc == m_preloaderScreen.logoAndkon )
			{
				navigateTo("http://www.andkon.com/arcade/");
			}
			else if( m_preloaderScreen != null && mc == m_preloaderScreen.armorLogo )
			{
				navigateTo("http://www.armorgames.com/");
			}
		}
		
		private function checkFrame(e:Event):void 
		{
			if (currentFrame == totalFrames) 
			{
				removeEventListener(Event.ENTER_FRAME, checkFrame);
				
				m_preloaderScreen.progressBar.bar.visible = false;
				m_preloaderScreen.startButton.visible = true;
				TweenMax.to( m_preloaderScreen.startButton, 0.5, { alpha:1 } );
				TweenMax.to( m_preloaderScreen.progressBar, 0.5, { alpha:0 } );
			}
		}
		
		private function onMouseDown(event:MouseEvent):void
		{
			m_preloaderScreen.startButton.gotoAndPlay(2);
		}
		
		private function onMouseUp(event:MouseEvent):void
		{
			startup();
		}
		
		private function startup():void 
		{
			if( GlobalData.adType == 1 && m_adLoaded == false )
				m_preloaderScreen.ngTank.ng_adObject.NG_Button.removeEventListener(MouseEvent.CLICK, loadNGSite);

			// hide loader
			TweenMax.killAllTweens();
			
			if( GlobalData.showBubbleBoxLogo )	unregisterButtonEvent(m_preloaderScreen.logoBubbleBox);
			if( GlobalData.showBelugerinLogo )	unregisterButtonEvent(m_preloaderScreen.logoBelugerin);
			if( GlobalData.showAndkonLogo )		unregisterButtonEvent(m_preloaderScreen.logoAndkon);
			
			m_preloaderScreen.startButton.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			m_preloaderScreen.startButton.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			removeChild(m_preloaderScreen);
			m_preloaderScreen = null;
			
			stop();
			
			loaderInfo.removeEventListener(ProgressEvent.PROGRESS, progress);
			var mainClass:Class = getDefinitionByName("Main") as Class;
			addChild(new mainClass() as DisplayObject);
		}
		
		private function navigateTo(url:String):void
		{
			var request:URLRequest = new URLRequest(url);
			navigateToURL(request);
		}
		
		private function siteLockTest(host:String):Boolean
		{
			var url:String=stage.loaderInfo.url;
			var urlStart:Number = url.indexOf("://")+3;
			var urlEnd:Number = url.indexOf("/", urlStart);
			var domain:String = url.substring(urlStart, urlEnd);
			var LastDot:Number = domain.lastIndexOf(".")-1;
			var domEnd:Number = domain.lastIndexOf(".", LastDot)+1;
			domain = domain.substring(domEnd, domain.length);
			
			return (domain == host) 
		}
		
		private function siteLockFilter():Boolean
		{
			var ret:Boolean = false;
			
			var filterCount:int = GlobalData.siteLockURLs.length;
			var counter:int = 0;
			
			while ( filterCount > 0 && ret == false && counter < filterCount )
			{
				var url:String = GlobalData.siteLockURLs[counter];
				ret = siteLockTest(url);
				
				counter++;
			}
			
			return ret;
		}
		
		private function getPlayerMajorVersionNumber():int
		{
			var ver:String = Capabilities.version;
			
			trace("Version:", ver);
			
			var firstSpace:int = ver.indexOf(" ");
			var firstComma:int = ver.indexOf(",");
			
			
			trace("First Space:", firstSpace);
			trace("First Comma:", firstComma);
			
			var majorVer:String = ver.substring(firstSpace, firstComma);
			trace("Major Ver:", majorVer);
			
			return int(majorVer);
		}
		
		
		//////////////////////////////////////////////////////////////////
		//			START NEWGROUNDS API
		//////////////////////////////////////////////////////////////////
		

		private function startAd(ngad_url:String):void 
		{
			var ad_loader:URLLoader = new URLLoader(new URLRequest(ngad_url));
			ad_loader.addEventListener(Event.COMPLETE,ad_Loaded);
		}

		private function ad_Loaded(event:Event):void 
		{
			m_adLoaded = true;
			var url:String = String(event.target.data);	
			var ad_loader:Loader = new Loader();
			ad_loader.load(new URLRequest(url));
			m_preloaderScreen.ngTank.ng_adObject.ng_ad.addChild(ad_loader);
		}

		private function loadNGSite(event:Event):void 
		{
			NewgroundsAPI.loadNewgrounds();
		}

		
		//////////////////////////////////////////////////////////////////
		//			END NEWGROUNDS API
		//////////////////////////////////////////////////////////////////

	}
	
}