package rj.helmet.entities;

import h2d.col.Bounds;
import haxe.EnumFlags;
import hxd.Res;
import rj.helmet.CooldownTimer;
import rj.helmet.dat.GameData;
import rj.helmet.Entity;
import rj.helmet.ParticleGenerator;
import rj.helmet.Projectile;

/**
 * The fireball explodes in smaller parts on contact or after a time.
 * 
 * @author roguedjack
 */
class FireballProjectile extends Projectile {
		
	var lifeTime:Float;
	var partOffset:Float;
	var trailFxTimer:CooldownTimer;
	var trailFxProjector:ParticleGenerator;
	var time:Float;
	var isSub:Bool;
	
	public function new(owner:Entity, vx:Float, vy:Float, isSub:Bool = false) {
		var data = GameData.FireballProjectile;
		super(owner, vx, vy, 
			isSub ? { power:data.power, spin:data.spin, speed:data.speed, gfx:data.gfx, colbox:data.colbox } 
				  : { power:data.sub_power, spin:data.sub_spin, speed:data.sub_speed, gfx:data.sub_gfx, colbox:data.sub_colbox } );					
		this.isSub = isSub;
		disableSameCollision = true;
		time = 0;
		lifeTime = (isSub ? data.sub_time : data.time);
		partOffset = data.sub_offset;
		trailFxTimer = new CooldownTimer(data.trailfx_period);
		trailFxProjector = new ParticleGenerator(DebrisParticle, [0xFF6400]);
		trailFxProjector.batchSize = isSub ? data.sub_particles : data.particles;
	}
	
	/**
	 * If main fireball will explode after a certain time, parts will die after a certain time.
	 * @param	elapsed
	 */
	override function updateLiving(elapsed:Float) {
		// trail fx
		if (trailFxTimer.update(elapsed)) {
			spawnTrailFx();
		}		
		
		// lifetime
		if (isSub) {
			if ((time += elapsed) >= lifeTime) {
				remove();
				return;
			}
			var t = time / lifeTime;
			bitmap.alpha = 1.0 - 0.75 * t * t;
		} else {
			if ((time += elapsed) >= lifeTime) {
				remove();
				explode();
				return;
			}
		}
		
		// super
		super.updateLiving(elapsed);
	}
	
	inline function spawnTrailFx() {
		trailFxProjector.emitBatch(bounds);
	}

	/**
	 * Base behavior + explode if not fireball part.
	 * @param	other
	 * @param	vx
	 * @param	vy
	 * @param	active
	 */
	override function onCollisionWith(other:Entity, vx:Float, vy:Float, active:Bool) {
		super.onCollisionWith(other, vx, vy, active);
		if (!isSub) {
			explode();
		}
	}
	
	/**
	 * Removed & explode if not fireball part.
	 * @param	colFlags
	 * @param	vx
	 * @param	vy
	 */
	override function onWorldCollision(colFlags:EnumFlags<ColFlags>, vx:Float, vy:Float) {
		remove();
		if (!isSub) {
			explode();
		}
		
	}
	
	/**
	 * Spawn smaller fireball parts in 8 directions.
	 */
	function explode() {
		playSfx(Res.sfx.fireball_explode_wav);
		
		var sx:Float, sy:Float;
		for (px in -1...2) {
			sx = pos.x + partOffset * px;
			for (py in -1...2) {
				if (px == 0 && py == 0) {
					continue;
				}
				sy = pos.y + partOffset * py;
				var part = new FireballProjectile(owner, px, py, true);
				world.spawnEntity(part, sx, sy);
			}
		}
	}
}