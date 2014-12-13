package rj.helmet.entities;

import haxe.EnumFlags;
import hxd.Res;
import rj.helmet.Entity;
import rj.helmet.Projectile;

/**
 * The arrow is fast and can bounce once on walls.
 * 
 * @author roguedjack
 */
class ArrowProjectile extends Projectile {
	
	public static inline var POWER = 3;
	public static inline var SPEED = 192.0;
	
	var bounced:Bool;
	
	public function new(owner:Entity, vx:Float, vy:Float) {
		super(owner, vx, vy, {
			spin:0,
			power:POWER
		}, { 
			speed:SPEED,
			health:0
		});
		setImage(Gfx.entities[19]);
		setCollisionBox(12, 12, 8, 8);
	}
	
	override function onStartSpawning() {
		super.onStartSpawning();
		bounced = false;
	}
	
	override function onWorldCollision(colFlags:EnumFlags<ColFlags>, vx:Float, vy:Float) {
		if (bounced) {
			remove();
		} else {
			playSfx(Res.sfx.arrow_bounce_wav);
			bounced = true;
			if (colFlags.has(ColFlags.COL_LEFT) || colFlags.has(ColFlags.COL_RIGHT)) {
				dx *= -1;
			}
			if (colFlags.has(ColFlags.COL_UP) || colFlags.has(ColFlags.COL_DOWN)) {
				dy *= -1;
			}
			faceDirection(dx, dy);
		}
		
	}
}