package rj.helmet.entities;

import h2d.Anim;
import h2d.col.Bounds;
import h2d.Tile;
import haxe.EnumFlags;
import hxd.Key;
import hxd.Res;
import rj.helmet.Actor;
import rj.helmet.CooldownTimer;
import rj.helmet.Entity;
import rj.helmet.Entity.EntityType;
import rj.helmet.Item.ItemType;
import rj.helmet.PlayerData;
import rj.helmet.WeaponMelee;
import rj.helmet.WeaponShooter;

@:enum abstract CharacterClass(Int) {
	var WARRIOR = 0;
	var VALKYRIE = 1;
	var ELF = 2;
}

class CharacterClassProps {
	public var colBox(default,default):Bounds;
	public var speed(default, default):Float;
	public var health(default, default):Int;
	public var weaponClass(default, default):Class<Projectile>;
	public var weaponCooldown(default, default):Float;
	public var meleeDamage(default, default):Int;
	public var meleeCooldown(default, default):Float;
	public var framesIdle(default, default):Array<Tile>;
	public var framesWalk(default, default):Array<Tile>;
	public var animSpeed(default, default):Int;
	
	public function new() {
	}
}

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
	
	public static inline var LIFELEAK_TIMER:Float = 1.0;
	public static inline var EXIT_LEVEL_TIMER:Float = 2.0;
	
	public static var CHARACTER_CLASSES_PROPS:Array<CharacterClassProps>;

	var data:PlayerData;
	var weapon:WeaponShooter;
	var melee:WeaponMelee;
	var lifeLeakTimer:CooldownTimer;
	var exitLevelTimer:CooldownTimer;

	public function new(data:PlayerData) {
		this.data = data;
		var cl = CHARACTER_CLASSES_PROPS[cast(data.characterClass, Int)];  // FIXME -- why do i need to cast an abstract int to an int?
		
		super(EntityType.PLAYER, { 
			speed:data.speed,
			health:data.health
		});
		
		setCollisionBox(Std.int(cl.colBox.xMin), Std.int(cl.colBox.yMin), Std.int(cl.colBox.width), Std.int(cl.colBox.height));		
		addAnim(ANIM_IDLE, new Anim(cl.framesIdle, cl.animSpeed));		
		addAnim(ANIM_WALK, new Anim(cl.framesWalk, 5));		
		equipWeapon(new WeaponShooter(this, cl.weaponClass, data.weaponCooldown));
		equipMelee(new WeaponMelee(this, data.meleeDamage, data.meleeCooldown));
		refreshHud();
	}
	
	function equipWeapon(shooter:WeaponShooter) {
		weapon = shooter;
	}
	
	function equipMelee(melee:WeaponMelee) {
		this.melee = melee;
	}
	
	function heal(amount:Int) {
		health += amount;
	}
	
	override function onStartSpawning() {
		super.onStartSpawning();
		playAnim(ANIM_IDLE);
		lifeLeakTimer = new CooldownTimer(LIFELEAK_TIMER);
	}

	override function updateLiving(elapsed:Float) {
		super.updateLiving(elapsed);
		
		// exiting level?
		if (exitLevelTimer != null) {
			if (exitLevelTimer.update(elapsed)) {
				Main.Instance.startNextLevel();
			} else {
				animExitingLevel(elapsed);
			}
			return;
		}
		
		// update weapons timer
		if (weapon != null) {
			weapon.update(elapsed);
		}
		if (melee != null) {
			melee.update(elapsed);
		}
		
		
		// shoot or move.
		// we can change direction while shooting.
		// melee is automatic when actively colliding with entities.
		var mx = 0, my = 0;
		var moving;
		if (Key.isDown(Key.UP) || Key.isDown(KEY_Z) || Key.isDown(KEY_W)) my -= 1;
		if (Key.isDown(Key.DOWN) || Key.isDown(KEY_S)) my += 1;
		if (Key.isDown(Key.LEFT) || Key.isDown(KEY_Q) || Key.isDown(Key.A)) mx -= 1;
		if (Key.isDown(Key.RIGHT) || Key.isDown(KEY_D)) mx += 1;							
		if (Key.isDown(Key.SPACE) || Key.isDown(Key.MOUSE_LEFT)) {
			if (weapon != null && weapon.canShoot) {
				playSfx(Res.sfx.shoot);
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
			move(mx * speed * elapsed, 0);
			move(0, my * speed * elapsed);
			playAnim(ANIM_WALK);			
		} else {			
			playAnim(ANIM_IDLE);
		}		
		
		// slowly loose life
		if (lifeLeakTimer.update(elapsed)) {
			takeDamage(null, 1);
			refreshHud();
		}
	}
	
	override function onCollisionWith(other:Entity, vx:Float, vy:Float, active:Bool) {		
		super.onCollisionWith(other, vx, vy, active);	
		
		switch (other.type) {
			case EntityType.EXIT: {
				if (exitLevelTimer == null) {
					startExitingLevel();
				}				
			}
			case EntityType.DOOR: {
				if (data.nbKeys > 0) {
					--data.nbKeys;
					refreshHud();					
					cast(other, DoorEntity).open();				
				}
			}			
			case EntityType.ITEM: {
				addToInventory(cast(other, Item));
				other.remove();
			}
			
			case EntityType.MONSTER: {
				if (active && melee.canStrike) {
					melee.strike(other);
				}
			}
			case EntityType.MONSTER_GENERATOR: {
				if (active && melee.canStrike) {
					melee.strike(other);
				}
			}
			
			default:
				// nop
		}
	}
	
	function startExitingLevel() {
		exitLevelTimer = new CooldownTimer(EXIT_LEVEL_TIMER);
		canCollide = false;							
		// TODO --- play sfx		
	}
	
	function animExitingLevel(elapsed:Float) {
		playAnim(ANIM_WALK);
		anchor.scale(1 - 0.9 * elapsed);			
		rotation += 4 * Math.PI * elapsed;		
	}
		
	function addToInventory(it:Item) {
		switch (it.itemType) {
			case ItemType.KEY:
				++data.nbKeys;
				playSfx(Res.sfx.pickup_key_wav);
				refreshHud();
			case ItemType.TREASURE:
				scorePoints(TreasureItem.SCORE);
				playSfx(Res.sfx.pickup_treasure_wav);
				refreshHud();
			case ItemType.HEALTH:
				heal(HealthItem.HEALTH);
				playSfx(Res.sfx.pickup_health_wav);
				refreshHud();
			default:
				// nop
		}		
	}
	
	inline function refreshHud() {
		Main.Instance.view.hud.refresh();		
	}
	
	public function scorePoints(pts:Int) {
		data.score += pts;
		refreshHud();
	}
	
	public static function initCharacterClasses() {		
		// the warrior is very strong.
		var warrior = new CharacterClassProps();
		warrior.colBox = Bounds.fromValues(8, 8, 16, 16);
		warrior.health = 10000;
		warrior.speed = 64.0;
		warrior.framesIdle = [Gfx.entities[8]];
		warrior.framesWalk = [Gfx.entities[9], Gfx.entities[10]];
		warrior.animSpeed = 5;
		warrior.weaponClass = AxeProjectile;
		warrior.weaponCooldown = 0.75;
		warrior.meleeDamage = 10;
		warrior.meleeCooldown = 0.50;
		
		// the valkyrie is average
		var valkyrie = new CharacterClassProps();
		valkyrie.colBox = Bounds.fromValues(10, 10, 12, 12);
		valkyrie.health = 9000;
		valkyrie.speed = 80.0;
		valkyrie.framesIdle = [Gfx.entities[12]];
		valkyrie.framesWalk = [Gfx.entities[13], Gfx.entities[14]];
		valkyrie.animSpeed = 7;
		valkyrie.weaponClass = SwordProjectile;
		valkyrie.weaponCooldown = 0.50;		
		valkyrie.meleeDamage = 5;
		valkyrie.meleeCooldown = 0.40;
		
		// the elf is fast
		var elf = new CharacterClassProps();
		elf.colBox = Bounds.fromValues(10, 10, 12, 12);
		elf.health = 7000;
		elf.speed = 112.0;
		elf.framesIdle = [Gfx.entities[16]];
		elf.framesWalk = [Gfx.entities[17], Gfx.entities[18]];
		elf.animSpeed = 10;
		elf.weaponClass = ArrowProjectile;
		elf.weaponCooldown = 0.35;		
		elf.meleeDamage = 3;
		elf.meleeCooldown = 0.35;		
		
		CHARACTER_CLASSES_PROPS = new Array<CharacterClassProps>();		
		CHARACTER_CLASSES_PROPS[cast(CharacterClass.WARRIOR, Int)] = warrior;   // FIXME -- why do i need to cast an abstract int to an int?
		CHARACTER_CLASSES_PROPS[cast(CharacterClass.VALKYRIE, Int)] = valkyrie;   // FIXME -- why do i need to cast an abstract int to an int?
		CHARACTER_CLASSES_PROPS[cast(CharacterClass.ELF,Int)] = elf;   // FIXME -- why do i need to cast an abstract int to an int?
	}
}