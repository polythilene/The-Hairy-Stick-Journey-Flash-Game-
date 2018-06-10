package 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.media.*;
	
	public class SoundManager extends EventDispatcher
	{
		static public const MUSIC_VOLUME:String = "music_volume";
		
		static private var m_instance:SoundManager;
				
		public const SOUNDTYPE_SFX:int = 0;
		public const SOUNDTYPE_MUSIC:int = 1;
		
		private var m_sfxList:Object;
		private var m_musicList:Object;
		
		private var m_sfxTransformer:SoundTransform;
		private var m_musicTransformer:SoundTransform;
		
		private var m_sfxEnable:Boolean;
		private var m_musicEnable:Boolean;
		
		
		public function SoundManager(lock:SingletonLock) 
		{
			m_sfxList = new Object();
			m_musicList = new Object();
			
			m_sfxTransformer = new SoundTransform();
			m_sfxTransformer.volume = 1;
			m_sfxEnable = true;
			
			m_musicTransformer = new SoundTransform();
			m_musicTransformer.volume = 1;
			m_musicEnable = true;
		}
		
		/* SOUND EFFECT HANDLER */
		
		public function addSFX( soundId:String, object:Sound ): void
		{
			m_sfxList[soundId] = new CSoundObject(object);
		}
			
		public function playSFX( soundId:String, loop:uint = 0 ): CSoundObject 
		{
			var sound:CSoundObject = m_sfxList[soundId];
			
			if( !sound )
				trace("Sound FX with ID:", soundId, "is not found!");
			else
			{
				if( m_sfxEnable )
					sound.play(loop, m_sfxTransformer);
			}
			
			return sound;
		}
		
		/* MUSIC HANDLER */
		
		public function addMusic( soundId:String, object:Sound ): void
		{
			m_musicList[soundId] = new CSoundObject(object, true);
		}
			
		public function playMusic( soundId:String, loop:uint = 0 ): CSoundObject 
		{
			var sound:CSoundObject = m_musicList[soundId];
			
			if( !sound )
				trace("Music with ID:", soundId, "is not found!");
			else
			{
				if ( musicEnable )
				{
					sound.play(loop, m_musicTransformer);
					m_musicTransformer.volume = 1;
				}
			}
			
			return sound;
		}
		
		/* CONTROLLER */
		
		public function set sfxVolume(value:Number):void
		{
			m_sfxTransformer.volume = value;
		}
		
		public function get sfxVolume():Number
		{
			return m_sfxTransformer.volume;
		}
		
		public function set musicVolume(value:Number):void
		{
			m_musicTransformer.volume = value;
			
			var event:SoundEvent = new SoundEvent(MUSIC_VOLUME);
			event.volume = value;
			dispatchEvent(event);
		}
		
		public function get musicVolume():Number
		{
			return m_musicTransformer.volume;
		}
		
		public function set sfxEnable(value:Boolean): void
		{
			m_sfxEnable = value;
		}
		
		public function get sfxEnable():Boolean
		{
			return m_sfxEnable;
		}
		
		public function set musicEnable(value:Boolean): void
		{
			m_musicEnable = value;
		}
		
		public function get musicEnable():Boolean
		{
			return m_musicEnable;
		}
		
		
		
		/* SINGLETON */
		
		static public function getInstance(): SoundManager
	    {
			if( m_instance == null ){
            	m_instance = new SoundManager( new SingletonLock() );
            }
			return m_instance;
	    }
	}
}

class SingletonLock{}