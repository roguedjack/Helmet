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
	public var power(default, default):Int;
	var dx:Float;
	var dy:Float;
	var projProps: {
		spin:Float,
		power:Int
	};

	/**
	 * 
	 * @param	owner shooter
	 * @param	dx direction
	 * @param	dy direction
	 * @param	projProps
	 * @param	actorProps
	 */
	public function new(owner:Entity, dx:Float, dy:Float, projProps, actorProps) {
		super(EntityType.PROJECTILE, actorProps);
		this.owner = owner;		
		this.dx = dx;
		this.dy = dy;		
		this.projProps = projProps;
		canCollide = true;
	}
	
	/**
	 * Move & spin
	 * @param	elapsed
	 */
	override function updateLiving(elapsed:Float) {
		super.updateLiving(elapsed);
		if (projProps.spin != 0) {
			rotation += projProps.spin * elapsed;
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
	 * Die immediatly and inflict damage to other.	 
	 * @param	other
	 * @param	vx
	 * @param	vy
	 * @param	active
	 */
	override function onCollisionWith(other:Entity, vx:Float, vy:Float, active:Bool) {
		super.onCollisionWith(other, vx, vy, active);
		
		state = ActorState.DEAD;
		
		switch (other.type) {
			case EntityType.MONSTER:
				cast(other, Actor).takeDamage(this, projProps.power);
			case EntityType.PLAYER:
				cast(other, Actor).takeDamage(this, projProps.power);
			case EntityType.MONSTER_GENERATOR:
				// TODO --- generators can take hits too
				other.remove();
			default:
				// no effect on other.
		}
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