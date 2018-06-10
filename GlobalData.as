package  
{
	/**
	 * ...
	 * @author Wiwit
	 */
	
	public class GlobalData
	{
		/* GLOBAL VARS */
		public static var showTutorial:Boolean = false;
		public static var animSpeed:Number = 1;
		
		/* LEVEL KEY */
		public static var levelAccess:Array = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false];
		
		/* SCORE COUNTER */
		static public var careerScore:int 		= 0;
		static public var levelFailCount:int 	= 0;
		
		/* ACHIEVEMENTS */
		static public var achievementFirstBlood:Boolean;
		
		static public var achievementISeeDeadStick:Boolean;	
		static public var achievementISeeDeadStickCounter:int;	
		
		static public var achievementFlawless:Boolean;
		
		static public var dino1Eat:Boolean;
		static public var dino2Eat:Boolean;
		static public var achievementDinoMeal:Boolean;
		
		static public var achievementTNTVictim:Boolean;
		static public var achievementTNTVictimCounter:int;
		
		static public var achievementBeingEvil:Boolean;
		
		static public var eatenByDinosaur:Boolean;
		static public var eatenByCrab:Boolean;
		static public var eatenByPiranha:Boolean;
		static public var eatenByCrocodile:Boolean;
		static public var achievementStickVersusWild:Boolean;	
		
		static public var achievementFinallyHome:Boolean;		
		
		static public var openingMovieFinished:Boolean;
		static public var endingMovieFinished:Boolean;
		static public var achievementMovieFreak:Boolean;
		//static public var achievementEventWatcher:Boolean;	// all event viewed (need special counter)
		
		/* ACHIEVEMENT STRING */
		static public var achievementString:Array = [];
		achievementString["firstBlood"]		= ["First Blood", "First time killed."];
		achievementString["iSeeDeadStick"]	= ["I See Dead Stick", "3X got killed."];
		achievementString["flawless"]		= ["Flawless", "Completing a level without accident."];
		achievementString["dinomeal"]		= ["Dino Meal", "Got eaten by dinosaurs...Yummy..."];
		achievementString["tntVictim"]		= ["TNT Victim", "3X got Blown up by TNT."];
		achievementString["beingEvil"]		= ["Being Evil", "Wear Jason mask."];
		achievementString["stickVersusWild"] = ["Stick VS. Wild", "Killed by various animals."];
		achievementString["finallyHome"]	= ["Finally Home", "Completing all levels."];
		achievementString["movieFreak"]		= ["Movie Freak", "Watch opening and ending movie until it's finished."];
		
		
		/* BRANDING CONFIG */
		static public const AD_CPMSTAR:int 		= 0;
		static public const AD_NEWGROUNDS:int 	= 1;
		static public const AD_YOUYOUWIN:int 	= 2;
		
		
		static public const showAd:Boolean = true;
		static public const adType:int = AD_CPMSTAR;				
		static public const siteLock:Boolean = false;
		//static public const siteLockURL:String = "armorgames.com";
		static public const siteLockURLs:Array = ["dailygames.com", "juegosdiarios.com", "jeuxdujour.com", "jogosdodia.com"];
		
		//static public const siteLockTrackbackURL:String = "http://www.bubblebox.com/clickreg.php?type=gamestats&id=1823&subid=sitelock";
		static public const siteLockTrackbackURL:String = "http://www.belugerinstudios.com/index.php?act=playgame&val=FL10062823";
		
		static public const newgroundsAPI:Boolean = false;
		static public const showBubbleBoxLogo:Boolean = false;
		static public const showBelugerinLogo:Boolean = true;
		static public const showAndkonLogo:Boolean = false;
		static public const showYouYouWinLogo:Boolean = false;
		static public const showArmorGamesLogo:Boolean = false;
		static public const showWalkthroughAndMoreGames:Boolean = false;
		
		
		/* NEWGROUNDS MEDAL */
		static public var ngMedals:Array = [];
		ngMedals["First Blood"]		= null;
		ngMedals["Dead Stick"]		= null;
		ngMedals["Flawless"]		= null;
		ngMedals["Dino Meal"]		= null;
		ngMedals["TNT Victim"]		= null;
		ngMedals["Being Evil"]		= null;
		ngMedals["Stick vs Wild"]	= null;
		ngMedals["Finaly Home"]		= null;
		ngMedals["Movie Freak"]		= null;
	}
}