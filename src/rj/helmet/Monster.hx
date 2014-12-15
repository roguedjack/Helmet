package rj.helmet;
import haxe.EnumFlags;
import hxd.Res;
import rj.helmet.Actor.ActorState;
import rj.helmet.Entity;
import rj.helmet.Entity.EntityType;
import rj.helmet.entities.PlayerActor;

/**
 * ...
 * @author roguedjack
 */
class Monster extends Actor {
		
	static inline var ANIM_IDLE = 0;
	static inline var ANIM_WALK = 1;
	
	/**
	 * Range below which the monster will be aggressive to the player.
	 */
	public var aggroRange(default, default):Float;
	public var score(default, null):Int;

	
	public var aiState(default, set):MonsterAIState;
	public var aiStateTime(default, null):Float;
	public var aiStateDistance(default, default):Float;
	public var aiStateStartPos(default, default): { x:Float, y:Float };
	
	var lastMoveX:Float;
	var lastMoveY:Float;
	var lastDir:Int;
	var moveCollidedWithPlayer:Bool;  // flag if we collided with the player in this frame movement
	
	
	// FIXME --- make up my mind : use props or simple parameters?
	public function new(props, aggroRange:Float=256, score:Int=10) {
		super(EntityType.MONSTER, props);
		canCollide = true;
		hardCollision = true;
		this.aggroRange = aggroRange;
		this.score = score;
		lastDir = 0;
		lastMoveX = lastMoveY = 0;
	}

	function set_aiState(s) {
		if (aiState != null) {
			aiState.onLeave(this);
		}
		aiState = s;
		aiStateTime = 0;
		s.onEnter(this);
		return s;
	}	
	
	override function updateLiving(elapsed:Float) {
		if (aiState != null) {
			aiStateTime += elapsed;
			aiState.onUpdate(this, elapsed);
		}
	}
	
	override function onCollisionWith(other:Entity, vx:Float, vy:Float, active:Bool) {
		if (active && other.type == EntityType.PLAYER) {
			moveCollidedWithPlayer = true;
		}
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
		
	//// Common behaviors
	
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
	 * Set a simple straight motion towards the player and face this direction.
	 * Will not move if the player is not living or beyond aggro range.
	 * 
	 * @param animIdle idle animation to play if does not wants to move
	 * @param animWalk walking animation to play if wants to walk
	 * @return the final movement
	 */
	/* OBSOLETE
	function doMoveStraightAtPlayer(elapsed:Float, animIdle:Int, animWalk:Int): { vx:Float, vy:Float } {
		var m: { vx:Float, vy:Float } = { vx:0, vy:0 };
		if (world.player == null || world.player.state != ActorState.LIVING) {
			playAnim(animIdle);
			return m;
		}
		var toPlayer = { dx:world.player.pos.x - pos.x, dy:world.player.pos.y - pos.y };
		if (Math.abs(toPlayer.dx) > aggroRange || Math.abs(toPlayer.dy) > aggroRange) {
			playAnim(animIdle);
			return m;
		}
		var l = Math.sqrt(toPlayer.dx * toPlayer.dx + toPlayer.dy * toPlayer.dy);
		if (l == 0) { // just to be safe...
			throw "distance to player is zero!";
		}
		toPlayer.dx /= l;
		toPlayer.dy /= l;
		faceDirection(toPlayer.dx, toPlayer.dy); // face where we would like to go
		playAnim(animWalk);		
		m.vx = elapsed * speed * toPlayer.dx;
		m.vy = elapsed * speed * toPlayer.dy;
		m.vx = move(m.vx, 0).vx;
		m.vy = move(0, m.vy).vy;
		return m;
	}
	*/
	/**
	 * Face another entity.
	 * Does not change facing if the target is null or change too small.
	 * @param	target can be null
	 */
	/* OBSOLETE
	function faceEntity(target:Entity) {
		if (target == null) {
			return;
		}
		var v = { vx:target.pos.x - pos.x, vy:target.pos.y - pos.y };
		if (v.vx != 0 || v.vy != 0) {
			faceDirection(v.vx, v.vy);		
		}
	}	
	*/
	
	/**
	 * Try to shoot at the player.
	 * Default does not shoot.
	 * @return true if fired a shot, false if didn't/couldn't
	 */
	public function tryShootingAtPlayer():Bool {
		return false;
	}
}