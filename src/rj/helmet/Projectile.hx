package rj.helmet;

import haxe.EnumFlags;
import rj.helmet.Actor.ActorState;
import rj.helmet.Actor.ColFlags;
import rj.helmet.Entity;
import rj.helmet.Entity.EntityType;

/**
 * ...
 * @author roguedjack
 */
class Projectile extends Actor {
	
	public var owner(default, null):Entity;
	var mx:Float;
	var my:Float;
	var spin:Float;

	/**
	 * 
	 * @param	owner shooter
	 * @param	mx motion
	 * @param	my motion
	 * @param	actorProps
	 */
	public function new(owner:Entity, mx:Float, my:Float, spin:Float, actorProps) {
		super(EntityType.PROJECTILE, actorProps);
		this.owner = owner;		
		this.spin = spin;
		this.mx = mx;
		this.my = my;		
		canCollide = true;
	}

	/**
	 * Start moving.
	 */
	override function onStartLiving() {
		motion = { dx:mx, dy:my };
	}
	
	/**
	 * Spin
	 * @param	elapsed
	 */
	override function updateBehavior(elapsed:Float) {
		if (spin != 0) {
			rotation += spin * elapsed;
		}
	}
	
	/**
	 * Don't collide with owner or exit.
	 * @param	other
	 * @return
	 */
	override function canCollideWith(other:Entity):Bool {
		return super.canCollideWith(other) && other != owner && other.type != EntityType.EXIT;
	}
	
	/**
	 * Dead immediatly.
	 * @param	elapsed
	 * @param	other
	 */
	override function onCollisionWith(elapsed:Float, other:Entity) {
		state = ActorState.DEAD;
	}
	
	/**
	 * Dead immediatly.
	 * @param	elapsed
	 * @param	colFlags
	 */
	override function onWorldCollision(elapsed:Float, colFlags:EnumFlags<ColFlags>) {
		state = ActorState.DEAD;
	}

}