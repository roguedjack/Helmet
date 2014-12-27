package rj.helmet.entities;

import haxe.EnumFlags;
import rj.helmet.Entity;
import rj.helmet.Entity.EntityType;
import rj.helmet.WeaponMelee;

/**
 * ...
 * @author roguedjack
 */
class PushableWall extends Entity {
	
	var crushPushForce:Float;
	var crushPushDuration:Float;
	var crush:WeaponMelee;
	var selfPushForce:Float;
	var selfPushDuration:Float;

	public function new(data) {
		super(EntityType.TRAP);
		setCollisionBox(data.colbox[0], data.colbox[1], data.colbox[2], data.colbox[3]);
		setImage(Gfx.entities[data.gfx]);
		canCollide = true;
		hardCollision = true;
		crush = new WeaponMelee(this, data.crush.damage, data.crush.cooldown);		
		crushPushForce = data.crush.pushForce;
		crushPushDuration = data.crush.pushDuration;
		selfPushForce = data.selfpush.force;
		selfPushDuration = data.selfpush.duration;
	}
	
	/**
	 *
	 * @param	elapsed
	 */
	override public function update(elapsed:Float) {
		super.update(elapsed);
		crush.update(elapsed);		
	}
	
	/**
	 * On active collision inflicts crush damage to damageable and push them.
	 * On passive collision is pushed by the other entity.
	 * @param	other
	 * @param	vx
	 * @param	vy
	 * @param	active
	 */
	override function onCollisionWith(other:Entity, vx:Float, vy:Float, active:Bool) {
		if (active) {
			if (crush.canStrike && Std.is(other, Damageable)) {			
				crush.strike(other);
				other.push(crushPushForce * vx, crushPushForce * vy, crushPushDuration);
			}
		} else {
			push(selfPushForce * vx, selfPushForce * vy, selfPushDuration);
		}
	}
}