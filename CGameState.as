package  
{
	import flash.display.DisplayObjectContainer;
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.net.navigateToURL;
    import flash.net.URLRequest;
	
	import com.newgrounds.API;
	import com.newgrounds.Medal;
	import com.newgrounds.components.MedalPopup;
	
	/**
	 * ...
	 * @author Kurniawan Fitriadi
	 */
	public class CGameState 
	{
		protected var m_owner:DisplayObjectContainer;
				
		public function CGameState() 
		{
		}
		
		public function get owner():DisplayObjectContainer
		{
			return m_owner;
		}
		
		public function get stage(): Stage
		{
			return m_owner.stage;
		}
		
		public function addChild(child:DisplayObject): DisplayObject
		{
			return m_owner.addChild(child);
		}
		
		public function addChildAt(child:DisplayObject, index:int): DisplayObject
		{
			return m_owner.addChildAt(child, index);
		}
		
		public function removeChild(child:DisplayObject): DisplayObject
		{
			return m_owner.removeChild(child);
		}
		
		/* achievement message */
		protected function achievementMessage(title:String, desc:String):void
		{
			trace("Achievement Unlocked", title, ":", desc);
		}
		
		protected function randomNumber(max:Number):Number 
		{
			return Math.random() * max;
		}
		
		protected function randomRange(minNum:Number, maxNum:Number):Number  
		{
			return ( Math.random() * (maxNum - minNum + 1) + minNum );
		}
		
		protected function navigateTo(url:String):void
		{
			trace("going to", url);
			
			var request:URLRequest = new URLRequest(url);
			navigateToURL(request);
		}
				
		private function loadNewgroundsMedal():void
		{
			GlobalData.ngMedals["First Blood"]		= API.getMedalByName("First Blood");
			GlobalData.ngMedals["Dead Stick"]		= API.getMedalByName("Dead Stick");
			GlobalData.ngMedals["Flawless"]			= API.getMedalByName("Flawless");
			GlobalData.ngMedals["Dino Meal"]		= API.getMedalByName("Dino Meal");
			GlobalData.ngMedals["TNT Victim"]		= API.getMedalByName("TNT Victim");
			GlobalData.ngMedals["Being Evil"]		= API.getMedalByName("Being Evil");
			GlobalData.ngMedals["Stick vs Wild"]	= API.getMedalByName("Stick vs Wild");
			GlobalData.ngMedals["Finaly Home"]		= API.getMedalByName("Finaly Home");
			GlobalData.ngMedals["Movie Freak"]		= API.getMedalByName("Movie Freak");
		}
		
		protected function unlockNewgroundsMedal(id:String):void
		{
			if( GlobalData.newgroundsAPI && 
				GlobalData.ngMedals[id] != null && 
				Medal(GlobalData.ngMedals[id]).unlocked == false )
			{
				API.unlockMedal(id);
				m_owner.addChild( new com.newgrounds.components.MedalPopup );
				GlobalData.ngMedals[id] = API.getMedalByName(id);
			}
		}
		
		
		/// DITURUNIN SMUA
		
		public function initialize(owner:DisplayObjectContainer): void
		{
			m_owner = owner;
		}
		
		public function enter(): void
		{
			/* load ng medals */
			
			if( GlobalData.newgroundsAPI )
				loadNewgroundsMedal();
		}
		
		public function exit(): void
		{
			/* ABSTRACT METHOD */
		}
		
		public function update(elapsedTime:int): void
		{
			/* ABSTRACT METHOD */
		}
		
	}

}