package rj.helmet;

import haxe.EnumFlags;
import rj.helmet.Actor.ActorState;
import rj.helmet.Entity;
import rj.helmet.Entity.ColFlags;
import rj.helmet.Entity.EntityType;

/**
 * ...
 * @author roguedjack
 */
class Projectile extends Actor {
	
	public var owner(default, null):Entity;
	var dx:Float;
	var dy:Float;
	var spin:Float;

	/**
	 * 
	 * @param	owner shooter
	 * @param	dx direction
	 * @param	dy direction
	 * @param	actorProps
	 */
	public function new(owner:Entity, dx:Float, dy:Float, spin:Float, actorProps) {
		super(EntityType.PROJECTILE, actorProps);
		this.owner = owner;		
		this.spin = spin;
		this.dx = dx;
		this.dy = dy;		
		canCollide = true;
	}
	
	/**
	 * Move & spin
	 * @param	elapsed
	 */
	override function updateLiving(elapsed:Float) {
		super.updateLiving(elapsed);
		if (spin != 0) {
			rotation += spin * elapsed;
		}		
		move(dx * elapsed * props.speed, dy * elapsed * props.speed);
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
	 * Die immediatly.
	 * @param	other
	 * @param	vx
	 * @param	vy
	 * @param	active
	 */
	override function onCollisionWith(other:Entity, vx:Float, vy:Float, active:Bool) {
		super.onCollisionWith(other, vx, vy, active);
		state = ActorState.DEAD;
	}
	
	/**
	 * Die immediatly.
	 * @param	colFlags
	 * @param	vx
	 * @param	vy
	 */
	override function onWorldCollision(colFlags:EnumFlags<ColFlags>, vx:Float, vy:Float) {
		super.onWorldCollision(colFlags, vx, vy);
		state = ActorState.DEAD;
	}
}