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
	var crush:WeaponMelee;

	public function new(isVertical:Bool, data) {
		super(EntityType.TRAP);
		setCollisionBox(data.colbox[0], data.colbox[1], data.colbox[2], data.colbox[3]);
		setImage(Gfx.entities[data.gfx]);
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
	 * Inflicts crush damage to player, monsters & generators.
	 * @param	other
	 * @param	vx
	 * @param	vy
	 * @param	active
	 */
	override function onCollisionWith(other:Entity, vx:Float, vy:Float, active:Bool) {
		if (active && crush.canStrike && (other.type == EntityType.PLAYER || other.type == EntityType.MONSTER || other.type == EntityType.MONSTER_GENERATOR)) {			
			crush.strike(other);
		}
	}
}