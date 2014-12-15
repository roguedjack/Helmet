package rj.helmet.entities;

import h2d.Anim;
import hxd.Res;
import rj.helmet.Actor.ActorState;
import rj.helmet.ai.AiStateIdle;
import rj.helmet.ai.AiStateMovingState;
import rj.helmet.ai.AiStatePathToPlayer;
import rj.helmet.Entity;
import rj.helmet.Monster;
import rj.helmet.MonsterAIState;
import rj.helmet.WeaponMelee;


/**
 * ...
 * @author roguedjack
 */
class GhostMonster extends Monster {

	private static inline var STRIKE_DMG = 5;
	private static inline var STRIKE_COOLDOWN = 1.0;
	private static inline var SPAWN_TIME = 1;
	private static inline var IDLE_TIME = 1;
	private static inline var MOVING_TIME = 1;
	
	var spawnTimer:Float;
	var startingHealth:Int;
	var strike:WeaponMelee;	
	
	static var LinkStates:Bool = true;
	static var StateIdle:AiStateIdle = new AiStateIdle(IDLE_TIME);
	static var StatePath:AiStatePathToPlayer = new AiStatePathToPlayer();
	static var StateMoving:AiStateMovingState = new AiStateMovingState(MOVING_TIME);

	public function new() {
		super({ 
			speed : 32, 
			health: 10
		});

		// FIXME -- a lot of monster types will have the same things, not particular to this type
		setCollisionBox(8, 8 , 16, 16);
		addAnim(Monster.ANIM_IDLE, new Anim([Gfx.entities[27]]));
		addAnim(Monster.ANIM_WALK, new Anim([Gfx.entities[28], Gfx.entities[29]], 2));
		
		strike = new WeaponMelee(this, STRIKE_DMG, STRIKE_COOLDOWN);
		
		if (LinkStates) {
			LinkStates = false;
			StateIdle.link(StatePath);
			StatePath.link(StateIdle, StateMoving);
			StateMoving.link(StateIdle, StatePath);
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
		
		super.updateLiving(elapsed);
				
		// FIXME -- a lot of monster types do the same thing, not particular to this type
		//OBSOLETE -- doMoveStraightAtPlayer(elapsed, ANIM_IDLE, ANIM_WALK);		
	}
	
	override public function takeDamage(source:Entity, dmg:Int) {
		super.takeDamage(source, dmg);
		
		// fade out to show health level
		var healthLevel = health / startingHealth;
		bitmap.alpha = 0.25 + 0.75 * healthLevel;
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
}