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
	
	var maxBounces:Int;
	var bouncesLeft:Int;
	
	public function new(owner:Entity, vx:Float, vy:Float) {
		super(owner, vx, vy, GameData.ArrowProjectile);
		disableSameCollision = true;
		maxBounces = GameData.ArrowProjectile.maxbounces;
	}
	
	override function onStartSpawning() {
		super.onStartSpawning();
		bouncesLeft = maxBounces;
	}
	
	override function onWorldCollision(colFlags:EnumFlags<ColFlags>, vx:Float, vy:Float) {
		bouncesLeft--;
		if (bouncesLeft < 0) {
			remove();
			onHit(vx, vy);
		} else {
			playSfx(Res.sfx.arrow_bounce_wav);
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