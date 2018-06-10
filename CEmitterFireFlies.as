package  
{
	import flash.geom.Point;
	import org.flintparticles.common.counters.Steady;
	import org.flintparticles.common.displayObjects.RadialDot;
	import org.flintparticles.common.initializers.ColorsInit;
	import org.flintparticles.common.initializers.SharedImage;
	import org.flintparticles.common.initializers.ColorInit;
	import org.flintparticles.common.initializers.Lifetime;
	import org.flintparticles.twoD.initializers.Velocity;
	import org.flintparticles.twoD.initializers.Position
	import org.flintparticles.common.actions.Age;
	import org.flintparticles.twoD.actions.Move;
	import org.flintparticles.twoD.zones.PointZone;
	import org.flintparticles.twoD.particles.Particle2D;
	import org.flintparticles.twoD.zones.RectangleZone;
	import org.flintparticles.twoD.actions.DeathZone;
	import org.flintparticles.twoD.actions.RandomDrift;
	import org.flintparticles.common.initializers.ScaleImageInit;
	import org.flintparticles.common.initializers.ImageClass
	//import org.flintparticles.common.initializers.SharedImages;
	import org.flintparticles.twoD.zones.LineZone;
	import org.flintparticles.common.actions.Fade;
	
	import org.flintparticles.common.energyEasing.Sine;
	import org.flintparticles.common.energyEasing.Bounce;
	
	
	/**
	 * ...
	 * @author Kurniawan Fitriadi
	 */
	public class CEmitterFireFlies extends CBaseEmitter
	{
		public function CEmitterFireFlies() 
		{
		}
		
		override protected function initialize():void 
		{
			super.initialize();
			
			m_lifeTime = 0;
			counter = new Steady( 0.7 );
			
			/* particle initializers */
			//addInitializer( new ImageClass( FireFlyBlue ) );
			addInitializer( new SharedImage( new FireFlyBlue() ) );
			addInitializer( new Position( new RectangleZone( 0, 50, 800, 450 ) ) );
			addInitializer( new Velocity( new PointZone( new Point( -25, -10 ) ) ) );
			addInitializer( new ScaleImageInit( 0.5 ) );
			addInitializer( new ColorsInit( new Array(0xFF00FF00, 0xFF33CC66, 0xFF82DCEC),
											new Array(0.4, 0.4, 0.4, 0.5) ) );
			addInitializer( new Lifetime( 5, 15 ) );								

			/* actions */
			addAction( new Move() );
			addAction( new DeathZone( new RectangleZone( -10, -10, 850, 490 ), true ) );
			addAction( new RandomDrift( 100, 70 ) );
			addAction( new Age( Bounce.easeInOut ) );
			addAction( new Fade() );
		}
		
		override public function reset(x:int, y:int):void 
		{
			super.reset(x, y);
			start();
		}
	}
}