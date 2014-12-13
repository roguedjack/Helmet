package rj.helmet.entities;

import h2d.col.Bounds;
import haxe.EnumFlags;
import hxd.Res;
import rj.helmet.CooldownTimer;
import rj.helmet.Entity;
import rj.helmet.ParticleGenerator;
import rj.helmet.Projectile;

/**
 * The fireball explodes in smaller parts on contact or after a time.
 * 
 * @author roguedjack
 */
class FireballProjectile extends Projectile {
	
	public static inline var POWER = 8;
	public static inline var SPEED = 128.0;
	public static inline var SPIN_DEG = 720.0;	
	public static inline var TIME_TO_EXPLOSION = 1;	
	public static inline var PART_POWER = 5;	
	public static inline var PART_SPEED = 160.0;
	public static inline var PART_OFFSET = 4;
	public static inline var PART_LIFETIME = 1;		
	public static inline var TRAILFX_PERIOD = 0.10;
	
	var trailFxTimer:CooldownTimer;
	var trailFxProjector:ParticleGenerator;
	var time:Float;
	var isPart:Bool;
	
	public function new(owner:Entity, vx:Float, vy:Float, isPart:Bool=false) {
		super(owner, vx, vy, {
			spin:SPIN_DEG * Math.PI / 180.0,			
			power:(isPart ? PART_POWER : POWER)
		}, { 
			speed:(isPart ? PART_SPEED : SPEED),
			health:0
		});
		this.isPart = isPart;		
		if (isPart) {
			setImage(Gfx.entities[31]);
			setCollisionBox(13, 13, 7, 7);
		} else {
			setImage(Gfx.entities[23]);			
			setCollisionBox(9, 9, 14, 14);
		}
		time = 0;
		trailFxTimer = new CooldownTimer(TRAILFX_PERIOD);
		trailFxProjector = new ParticleGenerator(DebrisParticle, [0xFF6400]);
		trailFxProjector.batchSize = isPart ? 4 : 8;
	}
	
	/**
	 * Does not collide with other fireballs fired by the same owner (eg: player fireballs wont collide with each other)
	 * @param	other
	 * @return
	 */
	override function canCollideWith(other:Entity):Bool {
		if (other.type == EntityType.PROJECTILE
			&& Std.is(other, FireballProjectile)
			&& cast(other, FireballProjectile).owner == owner) {
			return false;
		}
		return super.canCollideWith(other);
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
		if (isPart) {
			if ((time += elapsed) >= PART_LIFETIME) {
				remove();
				return;
			}
			var t = time / PART_LIFETIME;
			bitmap.alpha = 1.0 - 0.75 * t * t;
		} else {
			if ((time += elapsed) >= TIME_TO_EXPLOSION) {
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
		if (!isPart) {
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
		if (!isPart) {
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
			sx = pos.x + PART_OFFSET * px;
			for (py in -1...2) {
				if (px == 0 && py == 0) {
					continue;
				}
				sy = pos.y + PART_OFFSET * py;
				var part = new FireballProjectile(owner, px, py, true);
				world.spawnEntity(part, sx, sy);
			}
		}
	}
}