package rj.helmet;

import haxe.EnumFlags;
import hxd.Res;
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
	/**
	 * Disable collision with projectiles of the same concrete class fired by the same owner (default False).
	 * Eg: the player fireballs not colliding with other player fireballs.
	 */
	public var disableSameCollision(default, default):Bool;
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
	
	override function onStartSpawning() {
		super.onStartSpawning();
		faceDirection(dx, dy);
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
		move(dx * elapsed * speed, dy * elapsed * speed);
	}
	
	/**
	 * Don't collide with owner and collide only with hard collision.
	 * Additionally, if option `disableSameCollision` is set, don't collide with projectile of the same concrete class fired by the same owner.
	 * @param	other
	 * @return
	 */
	override function canCollideWith(other:Entity):Bool {
		if (disableSameCollision
			&& other != this 
			&& other.type == EntityType.PROJECTILE
			&& Std.is(other, Type.getClass(this))
			&& cast(other, Projectile).owner == owner) {
			return false;
		}		
		return super.canCollideWith(other) && other != owner && other.hardCollision;
	}

	/**
	 * Remove and inflict damage to other if monster/player/generator.
	 * @param	other
	 * @param	vx
	 * @param	vy
	 * @param	active
	 */
	override function onCollisionWith(other:Entity, vx:Float, vy:Float, active:Bool) {
		super.onCollisionWith(other, vx, vy, active);
		
		remove();
		
		switch (other.type) {
			case EntityType.MONSTER:
				cast(other, Actor).takeDamage(this, projProps.power);
			case EntityType.PLAYER:
				cast(other, Actor).takeDamage(this, projProps.power);
			case EntityType.MONSTER_GENERATOR:
				cast(other, MonsterGenerator).takeHit(this);
			default:
				// no effect on other.
		}
	}
	
	/**
	 * Remove.
	 * @param	colFlags
	 * @param	vx
	 * @param	vy
	 */
	override function onWorldCollision(colFlags:EnumFlags<ColFlags>, vx:Float, vy:Float) {
		super.onWorldCollision(colFlags, vx, vy);
		remove();
	}

}