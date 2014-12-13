package rj.helmet;
import haxe.EnumFlags;
import h2d.Tile;
import rj.helmet.Entity;

/**
 * ...
 * @author roguedjack
 */
class Particle extends Entity {
	
	/**
	 * Duration of the particle life.
	 */
	public var lifeTime(default, null):Float;
	/**
	 * Time in the particle life (time <= lifeTime)
	 */
	public var time(default, null):Float;
	/**
	 * Current X velocity
	 */
	public var vx(default, null):Float;
	/**
	 * Current Y velocity
	 */
	public var vy(default, null):Float;

	/**
	 * Concrete class should setup collision box & image.
	 * @param	img
	 * @param	lifeTime duration of the particle life
	 * @param	vx initial x velocity
	 * @param	vy initial y velocity
	 */
	function new(lifeTime:Float, vx:Float, vy:Float) {	
		super(EntityType.PARTICLE);
		this.lifeTime = lifeTime;
		this.vx = vx;
		this.vy = vy;
		canCollide = true;
		hardCollision = false;
		canForceWallAlignement = true;
	}
	
	override public function spawn(x:Float, y:Float) {
		super.spawn(x, y);
		time = 0;
	}
	
	/**
	 * Particles do not collide with any entity.
	 * @param	other
	 * @return
	 */
	override function canCollideWith(other:Entity):Bool {
		return false;
	}
	
	/**
	 * Particles are removed when colliding with world.
	 * @param	colFlags
	 * @param	vx
	 * @param	vy
	 */
	override function onWorldCollision(colFlags:EnumFlags<ColFlags>, vx:Float, vy:Float) {
		remove();
	}
	
	/**
	 * Update the motion, move the particle, update the effect and remove when life time ended.
	 * @param	elapsed
	 */
	override public function update(elapsed:Float) {
		super.update(elapsed);
		time += elapsed;
		if (time > lifeTime) {
			time = lifeTime;
		}
		updateMotion(elapsed);
		move(vx * elapsed, vy * elapsed);
		updateEffect(elapsed);		
		if (time >= lifeTime) {
			onLifetimeEnd();
			remove();
		}
	}
	
	/**
	 * Called before moving the particle, should update velocity.
	 * Default does nothing.
	 * @param	elapsed
	 */
	function updateMotion(elapsed:Float) { }
	
	/**
	 * Called after moving the particle, should update the graphics/sounds whatever...
	 * Default does nothing.
	 * @param	elapsed
	 */
	function updateEffect(elapsed:Float) { }
	
	/**
	 * Called when life time reached.
	 * Default does nothing.
	 */
	function onLifetimeEnd() { }
}