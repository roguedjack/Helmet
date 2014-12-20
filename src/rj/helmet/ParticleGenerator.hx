package rj.helmet;
import h2d.col.Bounds;

/**
 * ...
 * @author roguedjack
 */
class ParticleGenerator {
	
	public var particleClass(default, null):Class<Particle>;
	public var particleArgs(default, null):Array<Dynamic>;
	public var minLifetime(default, default):Float;
	public var maxLifetime(default, default):Float;	
	public var minVelocity(default, default):Float;
	public var maxVelocity(default, default):Float;
	public var batchSize(default, default):Int;

	/**
	 * 
	 * @param	particleClass constructor must accept the signature (lifeTime, vx, vy)
	 * @param	particleArgs additional arguments to pass to the particle constructor
	 * @param	minLifetime
	 * @param	maxLifetime
	 * @param	minVelocity
	 * @param	maxVelocity
	 * @param	batchSize
	 */
	public function new(particleClass:Class<Particle>, particleArgs:Array<Dynamic>, minLifetime:Float=0.5, maxLifetime:Float=1, minVelocity:Float=32, maxVelocity:Float=64, batchSize:Int=16) {
		this.particleClass = particleClass;
		this.particleArgs = particleArgs;
		this.minLifetime = minLifetime;
		this.maxLifetime = maxLifetime;
		this.minVelocity = minVelocity;
		this.maxVelocity = maxVelocity;
		this.batchSize = batchSize;
	}
	
	/**
	 * Spawn one particle at a position.
	 * @param	x
	 * @param	y
	 */
	public function emitParticle(x:Float, y:Float) {
		var vx = minVelocity + Math.random() * (maxVelocity - minVelocity);
		if (Math.random() < 0.5) vx = -vx;
		var vy = minVelocity + Math.random() * (maxVelocity - minVelocity);
		if (Math.random() < 0.5) vy = -vy;
		
		var lifeTime = minLifetime + Math.random() * (maxLifetime - minLifetime);
		
		var args = [ lifeTime, vx, vy ];
		for (a in particleArgs) {
			args.push(a);
		}
		var p:Particle = cast Type.createInstance(particleClass, args);
		Main.Instance.world.spawnEntity(p, x - 0.5 * p.size.width, y - 0.5 * p.size.height);
	}
	
	/**
	 * Spawn a batch of particles in an area.
	 * @param	area
	 */
	public function emitBatch(area:Bounds) {
		var x, y;
		for (i in 0...batchSize) {
			x = area.xMin + Math.random() * area.width;
			y = area.yMin + Math.random() * area.height;
			emitParticle(x, y);
		}
	}
	
}