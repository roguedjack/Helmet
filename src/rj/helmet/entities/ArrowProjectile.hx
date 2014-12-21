package rj.helmet.entities;

import haxe.EnumFlags;
import hxd.Res;
import rj.helmet.dat.GameData;
import rj.helmet.Entity;
import rj.helmet.Projectile;

/**
 * The arrow is fast and can bounce once on walls.
 * 
 * @author roguedjack
 */
class ArrowProjectile extends Projectile {
	
	var bounced:Bool;
	
	public function new(owner:Entity, vx:Float, vy:Float) {
		super(owner, vx, vy, GameData.ArrowProjectile);
		disableSameCollision = true;
	}
	
	override function onStartSpawning() {
		super.onStartSpawning();
		bounced = false;
	}
	
	override function onWorldCollision(colFlags:EnumFlags<ColFlags>, vx:Float, vy:Float) {
		if (bounced) {
			remove();
			onHit(vx, vy);
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