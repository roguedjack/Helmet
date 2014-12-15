package rj.helmet.entities;

import h2d.Anim;
import hxd.Res;
import rj.helmet.Actor.ActorState;
import rj.helmet.ai.AiStateIdle;
import rj.helmet.ai.AiStateMovingState;
import rj.helmet.ai.AiStatePathToPlayer;
import rj.helmet.ai.AiStateShootOrPathToPlayer;
import rj.helmet.Entity;
import rj.helmet.Monster;
import rj.helmet.MonsterAIState;
import rj.helmet.ParticleGenerator;
import rj.helmet.WeaponMelee;
import rj.helmet.WeaponShooter;
import rj.helmet.World;


/**
 * ...
 * @author roguedjack
 */
class DemonMonster extends Monster {

	private static inline var STRIKE_DMG = 5;
	private static inline var STRIKE_COOLDOWN = 1.0;
	private static inline var SHOOT_COOLDOWN = 1;	
	private static inline var SPAWN_TIME = 1;
	private static inline var IDLE_TIME = 0.5;
	private static inline var MOVING_TIME = 0.5;
	private static inline var AIMING_ANGULAR_ERROR_MARGIN_DEG = 10;
	private static inline var ANIM_SHOOT = 2;
	
	var spawnTimer:Float;
	var startingHealth:Int;
	var strike:WeaponMelee;	
	var shoot:WeaponShooter;
	var bloodProjector:ParticleGenerator;
	
	static var LinkStates:Bool = true;
	static var StateIdle:AiStateIdle = new AiStateIdle(IDLE_TIME);
	static var StateShootOrPath:AiStateShootOrPathToPlayer = new AiStateShootOrPathToPlayer();
	static var StateMoving:AiStateMovingState = new AiStateMovingState(MOVING_TIME);

	public function new() {
		super({ 
			speed : 32, 
			health: 10
		});

		// FIXME -- a lot of monster types will have the same things, not particular to this type
		setCollisionBox(8, 8 , 16, 16);
		addAnim(Monster.ANIM_IDLE, new Anim([Gfx.entities[35]]));
		addAnim(Monster.ANIM_WALK, new Anim([Gfx.entities[36], Gfx.entities[37]], 4));
		
		strike = new WeaponMelee(this, STRIKE_DMG, STRIKE_COOLDOWN);
		
		// particular to Demon
		addAnim(ANIM_SHOOT, new Anim([Gfx.entities[38]]));		
		shoot = new WeaponShooter(this, DemonShotProjectile, SHOOT_COOLDOWN);
		bloodProjector = new ParticleGenerator(DebrisParticle, [0xFF0000]);
		bloodProjector.minLifetime = 0.25;
		bloodProjector.maxLifetime = 0.5;
		bloodProjector.batchSize = 4;
		
		if (LinkStates) {
			LinkStates = false;
			StateIdle.link(StateShootOrPath);
			StateShootOrPath.link(StateIdle, StateMoving);
			StateMoving.link(StateIdle, StateShootOrPath);
		}
	}

	override function onStartSpawning() {
		// FIXME -- a lot of monster types do the same thing, not particular to this type
		super.onStartSpawning();
		startingHealth = health;
		spawnTimer = 0;
		rotation = Math.random() * 2 * Math.PI;
		playAnim(Monster.ANIM_IDLE);
		
		aiState = StateIdle;
	}
	
	override function updateSpawning(elapsed:Float) {		
		canCollide = true;
		spawnTimer += elapsed;
		if (spawnTimer >= SPAWN_TIME) {
			state = ActorState.LIVING;
			bitmap.alpha = 1;
		} else {
			bitmap.alpha = 0.25 + 0.75 * spawnTimer / SPAWN_TIME;
		}
	}	
	
	override function updateLiving(elapsed:Float) {		
		// FIXME -- a lot of monster types do the same thing, not particular to this type
		// weapon timers
		strike.update(elapsed);
		shoot.update(elapsed);
		
		super.updateLiving(elapsed);
				
		// FIXME -- a lot of monster types do the same thing, not particular to this type
		//OBSOLETE -- doMoveStraightAtPlayer(elapsed, ANIM_IDLE, ANIM_WALK);		
	}
	
	override public function takeDamage(source:Entity, dmg:Int) {
		super.takeDamage(source, dmg);
	
		// blood splatter
		bloodProjector.emitBatch(bounds);
	}
	
	override function onCollisionWith(other:Entity, vx:Float, vy:Float, active:Bool) {
		super.onCollisionWith(other, vx, vy, active);
		// FIXME -- a lot of monster types do the same thing, not particular to this type		
		// strike player in melee
		if (active && other.type == EntityType.PLAYER && strike.canStrike) {
			playSfx(Res.sfx.hit_wav);
			strike.strike(other);
		}
		
	}
	
	//// Shooting behavior
	
	// FIXME --- this should be common to all shooting monsters
	override public function tryShootingAtPlayer():Bool {
		if (shoot.canShoot) {
			if (isAimingAtPlayer(AIMING_ANGULAR_ERROR_MARGIN_DEG * Math.PI / 180.0)) {
				playSfx(Res.sfx.monster_shoot_wav);
				shoot.shoot();
				// play shoot anim & go back to idle state for small delay
				playAnim(ANIM_SHOOT);
				aiState = StateIdle;
				return true;
			}
		}
		return false;
	}
	
	// FIXME --- this should be common to all shooting monsters
	function isAimingAtPlayer(angularErrorMargin:Float):Bool {
		if (world.player == null || world.player.state != ActorState.LIVING) {
			return false;
		}
		var angleToPlayer = angleToDirection(world.player.pos.x - pos.x, world.player.pos.y - pos.y);
		return Math.abs(angleToPlayer - rotation) <= angularErrorMargin;
	}
}