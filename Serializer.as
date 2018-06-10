package  
{
	import flash.net.SharedObject;
	import com.newgrounds.API;
	
	/**
	 * ...
	 * @author Kurniawan Fitriadi
	 */
	public class Serializer
	{
		private const SERIALIZER_KEY:String = "_HARRYSTICK_R.02_";
		
		static private var m_instance:Serializer;
		
		public function Serializer(lock:SingletonLock) {}
		
		public function saveData():void
		{
			var m_shared:SharedObject = SharedObject.getLocal(SERIALIZER_KEY);
			
			/* level data */
			m_shared.data.level_access_0 = GlobalData.levelAccess[0];
			m_shared.data.level_access_1 = GlobalData.levelAccess[1];
			m_shared.data.level_access_2 = GlobalData.levelAccess[2];
			m_shared.data.level_access_3 = GlobalData.levelAccess[3];
			m_shared.data.level_access_4 = GlobalData.levelAccess[4];
			m_shared.data.level_access_5 = GlobalData.levelAccess[5];
			m_shared.data.level_access_6 = GlobalData.levelAccess[6];
			m_shared.data.level_access_7 = GlobalData.levelAccess[7];
			m_shared.data.level_access_8 = GlobalData.levelAccess[8];
			m_shared.data.level_access_9 = GlobalData.levelAccess[9];
			
			/* achievements */
			m_shared.data.achievementFirstBlood = GlobalData.achievementFirstBlood;
			m_shared.data.achievementISeeDeadStick = GlobalData.achievementISeeDeadStick;
			m_shared.data.achievementFlawless = GlobalData.achievementFlawless;
			m_shared.data.achievementDinoMeal = GlobalData.achievementDinoMeal;
			m_shared.data.achievementTNTVictim = GlobalData.achievementTNTVictim;
			m_shared.data.achievementBeingEvil = GlobalData.achievementBeingEvil;
			m_shared.data.achievementStickVersusWild = GlobalData.achievementStickVersusWild;
			m_shared.data.achievementFinallyHome = GlobalData.achievementFinallyHome;
			m_shared.data.achievementMovieFreak = GlobalData.achievementMovieFreak;
			
			m_shared.flush();
		}
		
		public function loadData():void
		{
			var m_shared:SharedObject = SharedObject.getLocal(SERIALIZER_KEY);
			
			/* level data */
			GlobalData.levelAccess[0] = m_shared.data.level_access_0;
			GlobalData.levelAccess[1] = m_shared.data.level_access_1;
			GlobalData.levelAccess[2] = m_shared.data.level_access_2;
			GlobalData.levelAccess[3] = m_shared.data.level_access_3;
			GlobalData.levelAccess[4] = m_shared.data.level_access_4;
			GlobalData.levelAccess[5] = m_shared.data.level_access_5;
			GlobalData.levelAccess[6] = m_shared.data.level_access_6;
			GlobalData.levelAccess[7] = m_shared.data.level_access_7;
			GlobalData.levelAccess[8] = m_shared.data.level_access_8;
			GlobalData.levelAccess[9] = m_shared.data.level_access_9;
			
			/* achievements */
			GlobalData.achievementFirstBlood = m_shared.data.achievementFirstBlood;
			GlobalData.achievementISeeDeadStick = m_shared.data.achievementISeeDeadStick;
			GlobalData.achievementFlawless = m_shared.data.achievementFlawless;
			GlobalData.achievementDinoMeal = m_shared.data.achievementDinoMeal;
			GlobalData.achievementTNTVictim = m_shared.data.achievementTNTVictim;
			GlobalData.achievementBeingEvil = m_shared.data.achievementBeingEvil;
			GlobalData.achievementStickVersusWild = m_shared.data.achievementStickVersusWild;
			GlobalData.achievementFinallyHome = m_shared.data.achievementFinallyHome;
			GlobalData.achievementMovieFreak = m_shared.data.achievementMovieFreak;
		}
		
		static public function getInstance(): Serializer
		{
			if( m_instance == null ){
				m_instance = new Serializer( new SingletonLock() );
			}
			return m_instance;
		}
	}
}

class SingletonLock{}