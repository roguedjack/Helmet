package rj.helmet;
import h2d.Anim;
import h2d.filter.Filter;
import h2d.filter.Glow;
import haxe.EnumFlags;
import hxd.Res;
import rj.helmet.Actor.ActorState;
import rj.helmet.ai.AiStateShootOrPathToPlayer;
import rj.helmet.dat.GameData;
import rj.helmet.Entity;
import rj.helmet.Entity.EntityType;
import rj.helmet.entities.PlayerActor;

// must import all monster projectiles for Type.createInstance
import rj.helmet.entities.DemonShotProjectile;
// end import

/**
 * ...
 * @author roguedjack
 */
class Monster extends Actor {
		
	static inline var ANIM_IDLE = 0;
	static inline var ANIM_WALK = 1;
	static inline var ANIM_SHOOT = 2;
	
	/**
	 * Range below which the monster will be aggressive to the player.
	 */
	public var aggroRange(default, default):Float;
	public var score(default, null):Int;

	
	public var aiState(default, set):MonsterAIState;
	public var aiStateTime(default, null):Float;
	public var aiStateDistance(default, default):Float;
	public var aiStateStartPos(default, default): { x:Float, y:Float };

	var spawnTime:Float;
	var spawnTimer:Float;
	var startingHealth:Int;	
	var strike:WeaponMelee;
	var shoot:WeaponShooter;
	var shootAngleMargin:Float;
	var aiIdleState:MonsterAIState;
	var lastMoveX:Float;
	var lastMoveY:Float;
	var lastDir:Int;
	var moveCollidedWithPlayer:Bool;  // flag if we collided with the player in this frame movement
	var spawnGlow:Glow;
	
	public function new(data) {
		super(EntityType.MONSTER, { 
			speed : data.speed, 
			health: data.health
		});
		setCollisionBox(data.colbox[0], data.colbox[1], data.colbox[2], data.colbox[3]);

		addAnim(ANIM_IDLE, new Anim(GameData.parseEntityFrames(data.framesIdle), data.animSpeed));
		addAnim(ANIM_WALK, new Anim(GameData.parseEntityFrames(data.framesWalk), data.animSpeed));
		if (data.framesShoot != null) {
			addAnim(ANIM_SHOOT, new Anim(GameData.parseEntityFrames(data.framesShoot), data.animSpeed));
		}
		
		strike = new WeaponMelee(this, data.melee.damage, 1.0 / data.melee.firerate);
		if (data.weapon != null) {
			shoot = new WeaponShooter(this, cast Type.resolveClass("rj.helmet.entities." + data.weapon.projectile), 1.0 / data.weapon.firerate);			
			shootAngleMargin = data.weapon.angleMargin;
		} else {
			shoot = null;
			shootAngleMargin = 0.0;
		}

		spawnTime = data.spawnTime;
		aggroRange = data.aggroRange;
		score = data.score;		
		canCollide = true;
		hardCollision = true;
		
		lastDir = 0;
		lastMoveX = lastMoveY = 0;
	}

	function set_aiState(s) {
		if (s == null) {
			throw "setting null ai state!";
		}
		if (aiState != null) {
			aiState.onLeave(this);
		}
		aiState = s;
		aiStateTime = 0;
		s.onEnter(this);
		return s;
	}	

	override function onStartSpawning() {	
		super.onStartSpawning();
		startingHealth = health;
		spawnTimer = 0;
		rotation = Math.random() * 2 * Math.PI;
		playAnim(ANIM_IDLE);
		bitmap.filters.push(spawnGlow = new Glow(0xB200FF, 1, 1, 4));
		aiState = aiIdleState;
	}		
	
	override function updateSpawning(elapsed:Float) {		
		canCollide = true;
		spawnTimer += elapsed;
		if (spawnTimer >= spawnTime) {
			bitmap.filters.remove(spawnGlow);
			spawnGlow = null;
			bitmap.alpha = 1;
			state = ActorState.LIVING;			
		} else {
			bitmap.alpha = 0.25 + 0.75 * spawnTimer / spawnTime;
		}
	}		
	
	override function updateLiving(elapsed:Float) {
		if (strike != null) {
			strike.update(elapsed);
		}
		if (shoot != null) {
			shoot.update(elapsed);
		}
		
		if (aiState != null) {
			aiStateTime += elapsed;
			aiState.onUpdate(this, elapsed);
		}
	}	
	
	override function onCollisionWith(other:Entity, vx:Float, vy:Float, active:Bool) {
		// remember we collided with player
		if (active && other.type == EntityType.PLAYER) {
			moveCollidedWithPlayer = true;
		}
		// strike on-friendly damageable in melee if we can
		if (active && strike.canStrike
			&& other.type != EntityType.MONSTER && other.type != EntityType.MONSTER_GENERATOR
			&& Std.is(other, Damageable)) {
			strike.strike(other);
		}
		// notify ai
		if (aiState != null) {
			aiState.onCollisionWith(this, other, vx, vy, active);
		}
	}
	
	override function onWorldCollision(colFlags:EnumFlags<ColFlags>, vx:Float, vy:Float) {
		if (aiState != null) {
			aiState.onWorldCollision(this, colFlags, vx, vy);
		}
	}
	
	override public function takeDamage(source:Entity, dmg:Int) {
		super.takeDamage(source, dmg);
		if (health > 0) {
			playSfx(Res.sfx.monster_hit_wav);
		} else {
			// score points if killed by player
			if (source.type == EntityType.PLAYER) {
				cast(source, PlayerActor).scorePoints(score);
			} else if (source.type == EntityType.PROJECTILE) {
				var proj = cast(source, Projectile);
				if (proj.owner != null && proj.owner.type == EntityType.PLAYER) {
					cast(proj.owner, PlayerActor).scorePoints(score);
				}
			}
		}
	}
	
	override function onStartDying() {
		super.onStartDying();
		playSfx(Res.sfx.monster_die);
	}
		
	//// Common behaviors for AI states
	
	// FIXME -- this should be an enum...
	static var DIR8 = [
		{dx:0, dy: -1 }, // 0-n
		{dx:1, dy: -1 }, // 1-ne
		{dx:1, dy: 0 },  // 2-e
		{dx:1, dy: 1 },  // 3-se
		{dx:0, dy: 1 },  // 4-s
		{dx:-1, dy: 1 }, // 5-sw
		{dx:-1, dy: 0 }, // 6-w
		{dx:-1, dy: -1 } //	7-nw
	];	
	// FIXME -- this should be an enum...
	static inline var DIR_N = 0;
	static inline var DIR_NE = 1;
	static inline var DIR_E = 2;
	static inline var DIR_SE = 3;
	static inline var DIR_S = 4;
	static inline var DIR_SW = 5;
	static inline var DIR_W = 6;
	static inline var DIR_NW = 7;
	
	inline function left(dir:Int):Int {
		return dir == 0 ? 7 : dir - 1;
	}
	
	inline function right(dir:Int):Int {
		return (dir + 1) % 8;
	}	

	public function continueLastMovement() {
		tryMove(lastMoveX, lastMoveY);
	}
	
	public function tryToMoveToThePlayer():Bool {
		// get dir to player
		var dir = dir8To(world.player, lastDir);
		
		// clear player collision flag
		moveCollidedWithPlayer = false;
		
		// try forward first
		lastDir = dir;
		if (tryMove(DIR8[dir].dx, DIR8[dir].dy) || moveCollidedWithPlayer) {
			return true;
		}
		// try left & right alternatives (45 deg)
		var l = left(dir);
		lastDir = l;		
		if (tryMove(DIR8[l].dx, DIR8[l].dy) || moveCollidedWithPlayer) {
			return true;
		}
		var r = right(dir);
		lastDir = r;		
		if (tryMove(DIR8[r].dx, DIR8[r].dy) || moveCollidedWithPlayer) {
			return true;
		}		
		// turn even more (90 deg)
		var ll = left(l);
		lastDir = ll;
		if (tryMove(DIR8[ll].dx, DIR8[ll].dy) || moveCollidedWithPlayer) {
			return true;
		}
		var rr = right(r);
		lastDir = rr;
		if (tryMove(DIR8[rr].dx, DIR8[rr].dy) || moveCollidedWithPlayer) {
			return true;
		}		
		// all sensible directions blocked.
		playAnim(ANIM_IDLE);
		lastDir = dir;
		faceDirection(DIR8[dir].dx, DIR8[dir].dy);
		lastMoveX = DIR8[dir].dx;
		lastMoveY = DIR8[dir].dy;
		return false;
	}
	
	public function tryMove(dx:Float, dy:Float):Bool {
		lastMoveX = dx;
		lastMoveY = dy;
		playAnim(ANIM_WALK);
		faceDirection(dx, dy);		
		var m = move(dx * world.elapsed * speed, dy * world.elapsed * speed);
		return (dx == 0 || m.vx != 0) && (dy == 0 || m.vy != 0);
	}
	
	function dir8To(e:Entity, none:Int): Int {
		// check xy directions but add a margin to avoid flickering.
		var ymargin = 0.5 * (colBox.height + e.colBox.height);
		var xmargin = 0.5 * (colBox.width + e.colBox.width);
		var n = (e.pos.y < pos.y - ymargin);
		var s = (e.pos.y > pos.y + ymargin);
		var w = (e.pos.x < pos.x - xmargin);
		var e = (e.pos.x > pos.x + xmargin);
		
		return (n && w ? DIR_NW :
				n && e ? DIR_NE :
				s && w ? DIR_SW :
				s && e ? DIR_SE :
				e ? DIR_E :
				w ? DIR_W :
				n ? DIR_N :
				s ? DIR_S :
				none);
	}
	
	/**
	 * Try to shoot at the player.
	 * 
	 * @return true if fired a shot, false if didn't/couldn't
	 */	
	public function tryShootingAtPlayer():Bool {
		if (shoot == null) {
			return false;
		}
		if (shoot.canShoot) {
			if (isAimingAtPlayer(shootAngleMargin * Math.PI / 180.0)) {
				playSfx(Res.sfx.monster_shoot_wav);
				shoot.shoot();
				playAnim(ANIM_SHOOT);
				aiState = aiIdleState;
				return true;
			}
		}
		return false;
	}
	
	function isAimingAtPlayer(angularErrorMargin:Float):Bool {
		if (world.player == null || world.player.state != ActorState.LIVING) {
			return false;
		}
		var angleToPlayer = angleToDirection(world.player.pos.x - pos.x, world.player.pos.y - pos.y);
		return Math.abs(angleToPlayer - rotation) <= angularErrorMargin;
	}
	
}