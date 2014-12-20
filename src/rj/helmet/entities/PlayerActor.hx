package rj.helmet.entities;

import h2d.Anim;
import h2d.col.Bounds;
import h2d.filter.Glow;
import h2d.Tile;
import haxe.EnumFlags;
import hxd.Key;
import hxd.Res;
import rj.helmet.Actor;
import rj.helmet.CooldownTimer;
import rj.helmet.dat.GameData;
import rj.helmet.entities.PlayerActor.CharacterClassProps;
import rj.helmet.Entity;
import rj.helmet.Entity.EntityType;
import rj.helmet.fx.HurtEntityFx;
import rj.helmet.fx.TemporaryBonusFx;
import rj.helmet.Item.ItemType;
import rj.helmet.ParticleGenerator;
import rj.helmet.PlayerSaveData;
import rj.helmet.WeaponMelee;
import rj.helmet.WeaponShooter;

// must import all character projectile types for Type.resolveClass
import rj.helmet.entities.ArrowProjectile;
import rj.helmet.entities.AxeProjectile;
import rj.helmet.entities.FireballProjectile;
import rj.helmet.entities.SwordProjectile;
// end import projectiles

@:enum abstract CharacterClass(Int) {
	var WARRIOR = 0;
	var VALKYRIE = 1;
	var ELF = 2;
	var WIZARD = 3;
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
	
	public static function fromData(data):CharacterClassProps {
		var p = new CharacterClassProps();
		p.colBox = Bounds.fromValues(data.colbox[0], data.colbox[1], data.colbox[2], data.colbox[3]);
		p.speed = data.speed;
		p.health = data.health;
		var wpnClassname = "rj.helmet.entities." + data.weapon.projectile;
		p.weaponClass = cast Type.resolveClass(wpnClassname);
		if (p.weaponClass == null) {
			throw "unknown character weapon class " + wpnClassname;
		}
		p.weaponCooldown = 1.0 / data.weapon.firerate;
		p.meleeDamage = data.melee.damage;
		p.meleeCooldown = 1.0 / data.melee.firerate;
		p.framesIdle = GameData.parseEntityFrames(data.framesIdle);
		p.framesWalk = GameData.parseEntityFrames(data.framesWalk);
		p.animSpeed = data.animSpeed;
		return p;
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
	public static inline var HURTEFFECT_DURATION:Float = 0.25;
	
	public static var CHARACTER_CLASSES_PROPS:Array<CharacterClassProps>;

	public var weapon(default,null):WeaponShooter;
	public var melee(default,null):WeaponMelee;	
	var save:PlayerSaveData;
	var lifeLeakTimer:CooldownTimer;
	var exitLevelTimer:CooldownTimer;
	var hurtFx:HurtEntityFx;
	var shield:ShieldAttachement;

	public function new(save:PlayerSaveData) {
		this.save = save;
		var cl = CHARACTER_CLASSES_PROPS[cast(save.characterClass, Int)];  // FIXME -- why do i need to cast an abstract int to an int?
		
		super(EntityType.PLAYER, { 
			speed:cl.speed,
			health:save.health
		});
		
		setCollisionBox(Std.int(cl.colBox.xMin), Std.int(cl.colBox.yMin), Std.int(cl.colBox.width), Std.int(cl.colBox.height));		
		addAnim(ANIM_IDLE, new Anim(cl.framesIdle, cl.animSpeed));		
		addAnim(ANIM_WALK, new Anim(cl.framesWalk, cl.animSpeed));		
		equipWeapon(new WeaponShooter(this, cl.weaponClass, cl.weaponCooldown));
		equipMelee(new WeaponMelee(this, cl.meleeDamage, cl.meleeCooldown));
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
		
	function applyBonus(b:BonusItem) {
		var fx = new TemporaryBonusFx(b, b.duration); 
		startFx(fx);
	}
	
	override function onStartSpawning() {
		super.onStartSpawning();
		
		playAnim(ANIM_IDLE);
		new ParticleGenerator(SpriteParticle, [Gfx.entities[48], [14, 14, 4, 4]], 1.0, 2.0, 8.0, 16.0, 32).emitBatch(bounds);
		playSfx(Res.sfx.spawning_wav);		
		
		lifeLeakTimer = new CooldownTimer(LIFELEAK_TIMER);
		hurtFx = new HurtEntityFx(HURTEFFECT_DURATION);
		
		// special: valkyrie shield
		if (save.characterClass == CharacterClass.VALKYRIE) {
			var shieldData = GameData.ValkyrieCharacter.shield;
			shield = new ShieldAttachement(this, shieldData.xanchor, shieldData.yanchor, Gfx.entities[shieldData.gfx], shieldData.colbox);
			world.spawnEntity(shield, pos.x, pos.y);			
		} else {
			shield = null;
		}
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
		
		// shield only up when not moving or reloading
		if (shield != null) {
			var shieldUp = !moving && weapon.canShoot && melee.canStrike;
			shield.isVisible = shieldUp;
			shield.canCollide = shieldUp;
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
				if (save.nbKeys > 0) {
					--save.nbKeys;
					refreshHud();					
					cast(other, DoorEntity).open();				
				}
			}			
			case EntityType.ITEM: {
				addToInventory(cast(other, Item));
				other.remove();
			}
			
			default:
				// nop								
		}
		
		if (active && melee.canStrike && Std.is(other, Damageable)) {
			melee.strike(other);
		}	
	}
	
	override public function takeDamage(source:Entity, dmg:Int) {
		super.takeDamage(source, dmg);
		// hit sfx
		if (source != null) {
			playSfx(Res.sfx.hit_wav);
		}
		//  hurt fx
		if (source != null) {
			if (hurtFx.isActive) {
				hurtFx.extendDuration(HURTEFFECT_DURATION);
			} else {
				hurtFx.resetDuration(HURTEFFECT_DURATION);
				startFx(hurtFx);
			}
		}
	}
	
	function startExitingLevel() {
		exitLevelTimer = new CooldownTimer(EXIT_LEVEL_TIMER);
		canCollide = false;				
		new ParticleGenerator(SpriteParticle, [Gfx.entities[48], [14, 14, 4, 4]], 1.0, 2.0, 8.0, 16.0, 32).emitBatch(bounds);
		playSfx(Res.sfx.despawning_wav);
	}
	
	function animExitingLevel(elapsed:Float) {
		playAnim(ANIM_WALK);
		anchor.scale(1 - 0.9 * elapsed);			
		rotation += 4 * Math.PI * elapsed;		
	}
		
	function addToInventory(it:Item) {
		if (Std.is(it, BonusItem)) {
			applyBonus(cast(it, BonusItem));
			playSfx(Res.sfx.pickup_bonus_wav);
			refreshHud();
		} else {		
			switch (it.itemType) {
				case ItemType.KEY:
					++save.nbKeys;
					playSfx(Res.sfx.pickup_key_wav);
					refreshHud();
				case ItemType.TREASURE:
					scorePoints(cast(it, TreasureItem).score);
					playSfx(Res.sfx.pickup_treasure_wav);
					refreshHud();
				case ItemType.HEALTH:
					heal(cast(it, HealthItem).health);
					playSfx(Res.sfx.pickup_health_wav);
					refreshHud();				
				default:
					// nop
			}		
		}
	}
	
	inline function refreshHud() {
		Main.Instance.view.hud.refresh();		
	}
	
	public function scorePoints(pts:Int) {
		save.score += pts;
		refreshHud();
	}
	
	public static function initCharacterClasses() {		
		var warrior = CharacterClassProps.fromData(GameData.WarriorCharacter);
		var valkyrie = CharacterClassProps.fromData(GameData.ValkyrieCharacter);
		var elf = CharacterClassProps.fromData(GameData.ElfCharacter);
		var wizard = CharacterClassProps.fromData(GameData.WizardCharacter);		
		
		CHARACTER_CLASSES_PROPS = new Array<CharacterClassProps>();		
		CHARACTER_CLASSES_PROPS[cast(CharacterClass.WARRIOR, Int)] = warrior;   // FIXME -- why do i need to cast an abstract int to an int?
		CHARACTER_CLASSES_PROPS[cast(CharacterClass.VALKYRIE, Int)] = valkyrie;   // FIXME -- why do i need to cast an abstract int to an int?
		CHARACTER_CLASSES_PROPS[cast(CharacterClass.ELF, Int)] = elf;   // FIXME -- why do i need to cast an abstract int to an int?
		CHARACTER_CLASSES_PROPS[cast(CharacterClass.WIZARD,Int)] = wizard;   // FIXME -- why do i need to cast an abstract int to an int?
	}
}