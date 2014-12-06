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
	
	private static inline var KEY_D = Key.A + ('d'.code - 'a'.code);
	private static inline var KEY_Q = Key.A + ('q'.code - 'a'.code);
	private static inline var KEY_S = Key.A + ('s'.code - 'a'.code);
	private static inline var KEY_W = Key.A + ('w'.code - 'a'.code);
	private static inline var KEY_Z = Key.A + ('z'.code - 'a'.code);
	
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

	override function updateBehavior(elapsed:Float) {
		super.updateBehavior(elapsed);
		
		// update weapon timer
		if (weapon != null) {
			weapon.update(elapsed);
		}
		
		// shoot or move.
		// we can change direction while shooting.
		var mx = 0, my = 0;
		if (Key.isDown(Key.UP) || Key.isDown(KEY_Z) || Key.isDown(KEY_W)) my -= 1;
		if (Key.isDown(Key.DOWN) || Key.isDown(KEY_S)) my += 1;
		if (Key.isDown(Key.LEFT) || Key.isDown(KEY_Q) || Key.isDown(Key.A)) mx -= 1;
		if (Key.isDown(Key.RIGHT) || Key.isDown(KEY_D)) mx += 1;							
		if (Key.isDown(Key.SPACE) || Key.isDown(Key.MOUSE_LEFT)) {
			if (weapon != null && weapon.canShoot) {
				weapon.shoot();
			}
			motion = { dx:0, dy:0 };
		} else {			
			motion = { dx:mx, dy:my };
		}
		if (mx != 0 || my != 0) {
			faceDirection(mx, my);
		}
				
		// anim move
		if (motion.dx != 0 || motion.dy != 0) {
			playAnim(ANIM_WALK);
		} else {
			playAnim(ANIM_IDLE);
		}		
	}
	
	override function onCollisionWith(elapsed:Float, other:Entity) {
		super.onCollisionWith(elapsed, other);
		if (other.type == EntityType.EXIT) {
			// spin madly!
			rotation += 4 * Math.PI * elapsed;
		}
	}
}