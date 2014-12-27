package rj.helmet.entities;

import haxe.EnumFlags;
import rj.helmet.Entity;
import rj.helmet.Entity.EntityType;
import rj.helmet.WeaponMelee;

/**
 * ...
 * @author roguedjack
 */
class MovingWall extends Entity {
	
	var mx:Float;
	var my:Float;
	var speed:Float;
	var pushForce:Float;
	var pushDuration:Float;
	var crush:WeaponMelee;

	public function new(isVertical:Bool, data) {
		super(EntityType.TRAP);
		var index = (isVertical ? 0 : 1);
		setCollisionBox(data.colbox[index][0], data.colbox[index][1], data.colbox[index][2], data.colbox[index][3]);
		setImage(Gfx.entities[data.gfx[index]]);
		speed = data.speed;
		canCollide = true;
		hardCollision = true;
		if (isVertical) {
			mx = 0;
			my = 1;
		} else {
			mx = 1;
			my = 0;
		}
		crush = new WeaponMelee(this, data.crush.damage, data.crush.cooldown);		
		pushForce = data.crush.pushForce;
		pushDuration = data.crush.pushDuration;
	}
	
	/**
	 * Keep moving.
	 * @param	elapsed
	 */
	override public function update(elapsed:Float) {
		super.update(elapsed);
		crush.update(elapsed);		
		var m = speed * elapsed;
		move(mx * m, my * m);		
	}
	
	/**
	 * Reverse direction on world collision.
	 * @param	colFlags
	 * @param	vx
	 * @param	vy
	 */
	override function onWorldCollision(colFlags:EnumFlags<ColFlags>, vx:Float, vy:Float) {
		mx *= -1;
		my *= -1;
	}
	
	/**
	 * Inflicts crush damage to damageable and push them.
	 * @param	other
	 * @param	vx
	 * @param	vy
	 * @param	active
	 */
	override function onCollisionWith(other:Entity, vx:Float, vy:Float, active:Bool) {
		if (active && crush.canStrike && Std.is(other, Damageable)) {			
			crush.strike(other);
			other.push(pushForce * mx, pushForce * my, pushDuration);
		}
	}
}