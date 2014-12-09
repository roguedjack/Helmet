package rj.helmet.entities;

import h2d.Anim;
import haxe.EnumFlags;
import hxd.Key;
import rj.helmet.Actor;
import rj.helmet.Entity;
import rj.helmet.Entity.EntityType;
import rj.helmet.WeaponShooter;

/**
 * ...
 * @author roguedjack
 */
class PlayerActor extends Actor {

	private static inline var ANIM_IDLE = 0;
	private static inline var ANIM_WALK = 1;
	
	public static inline var KEY_D = Key.A + ('d'.code - 'a'.code);
	public static inline var KEY_Q = Key.A + ('q'.code - 'a'.code);
	public static inline var KEY_S = Key.A + ('s'.code - 'a'.code);
	public static inline var KEY_W = Key.A + ('w'.code - 'a'.code);
	public static inline var KEY_Z = Key.A + ('z'.code - 'a'.code);
	
	var weapon:WeaponShooter;

	public function new() {
		super(EntityType.PLAYER, { speed:64.0 } );
		setCollisionBox(8, 8, 16, 16);
		
		addAnim(ANIM_IDLE, new Anim([Gfx.entities[8]]));		
		addAnim(ANIM_WALK, new Anim([Gfx.entities[9], Gfx.entities[10]], 5));
		
		equipWeapon(new WeaponShooter(this, AxeProjectile, 0.75));
	}
	
	function equipWeapon(shooter:WeaponShooter) {
		weapon = shooter;
	}
	
	override function onStartSpawning() {
		super.onStartSpawning();
		playAnim(ANIM_IDLE);
	}

	override function updateLiving(elapsed:Float) {
		super.updateLiving(elapsed);
		
		// update weapon timer
		if (weapon != null) {
			weapon.update(elapsed);
		}
		
		// shoot or move.
		// we can change direction while shooting.
		var mx = 0, my = 0;
		var moving;
		if (Key.isDown(Key.UP) || Key.isDown(KEY_Z) || Key.isDown(KEY_W)) my -= 1;
		if (Key.isDown(Key.DOWN) || Key.isDown(KEY_S)) my += 1;
		if (Key.isDown(Key.LEFT) || Key.isDown(KEY_Q) || Key.isDown(Key.A)) mx -= 1;
		if (Key.isDown(Key.RIGHT) || Key.isDown(KEY_D)) mx += 1;							
		if (Key.isDown(Key.SPACE) || Key.isDown(Key.MOUSE_LEFT)) {
			if (weapon != null && weapon.canShoot) {
				weapon.shoot();
			}
			moving = false;
		} else {
			moving = (mx != 0 || my != 0);
		}
		if (mx != 0 || my != 0) {
			faceDirection(mx, my);		
		}
		if (moving) {
			move(mx * props.speed * elapsed, 0);
			move(0, my * props.speed * elapsed);
			playAnim(ANIM_WALK);			
		} else {			
			playAnim(ANIM_IDLE);
		}		
	}
	
	override function onCollisionWith(other:Entity, vx:Float, vy:Float, active:Bool) {		
		super.onCollisionWith(other, vx, vy, active);	
		if (other.type == EntityType.EXIT) {
			// spin madly!
			// FIXME --- we collide only when moving, but when we move we set the rotation so this now has no effect.
			rotation += 4 * Math.PI * world.elapsed;
		}
	}
}