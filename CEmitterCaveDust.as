package  
{
	import flash.geom.Point;
	import org.flintparticles.common.actions.ScaleImage;
	import org.flintparticles.common.counters.Steady;
	import org.flintparticles.common.displayObjects.RadialDot;
	import org.flintparticles.common.initializers.AlphaInit;
	import org.flintparticles.common.initializers.ColorsInit;
	import org.flintparticles.common.initializers.SharedImage;
	import org.flintparticles.common.initializers.ColorInit;
	import org.flintparticles.common.initializers.Lifetime;
	import org.flintparticles.twoD.actions.Rotate;
	import org.flintparticles.twoD.actions.RotateToDirection;
	import org.flintparticles.twoD.actions.RotationalFriction;
	import org.flintparticles.twoD.initializers.Rotation;
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
	import org.flintparticles.twoD.zones.LineZone;
	import org.flintparticles.common.actions.Fade;
	
	import org.flintparticles.common.energyEasing.Sine;
	import org.flintparticles.common.energyEasing.Bounce;
	
	
	/**
	 * ...
	 * @author Kurniawan Fitriadi
	 */
	public class CEmitterCaveDust extends CBaseEmitter
	{
		public function CEmitterCaveDust() 
		{
		}
		
		override protected function initialize():void 
		{
			super.initialize();
			
			m_lifeTime = 0;
			counter = new Steady( 0.7 );
			
			/* particle initializers */
			addInitializer( new SharedImage( new mcCaveDust() ) );
			addInitializer( new Position( new RectangleZone( 900, 250, 1000, 450 ) ) );
			addInitializer( new Velocity( new PointZone( new Point( -50/*-25*/, -10 ) ) ) );
			addInitializer( new ScaleImageInit( 0.5, 1.0 ) );
			addInitializer( new Lifetime( 5, 20 ) );
			addInitializer( new AlphaInit( 0.75 ) );
			addInitializer( new Rotation(0, 180) );

			/* actions */
			addAction( new Move() );
			addAction( new DeathZone( new RectangleZone( -10, -10, 1500, 490 ), true ) );
			addAction( new RandomDrift( 100, 70 ) );
			addAction( new Age() );
			addAction( new Rotate() );
			addAction( new Fade() );
		}
		
		override public function reset(x:int, y:int):void 
		{
			super.reset(x, y);
			start();
		}
	}
}