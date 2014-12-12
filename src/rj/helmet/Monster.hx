package rj.helmet;
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
	
	/**
	 * Range below which the monster will be aggressive to the player.
	 */
	public var aggroRange(default, default):Float;
	public var score(default, null):Int;

	// FIXME --- make up my mind : use props or simple parameters?
	public function new(props, aggroRange:Float=256, score:Int=10) {
		super(EntityType.MONSTER, props);
		canCollide = true;
		hardCollision = true;
		this.aggroRange = aggroRange;
		this.score = score;
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
	
	/**
	 * Set a simple straight motion towards the player and face this direction.
	 * Will not move if the player is not living or beyond aggro range.
	 * 
	 * @param animIdle idle animation to play if does not wants to move
	 * @param animWalk walking animation to play if wants to walk
	 * @return the final movement
	 */
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
	
	/**
	 * Face another entity.
	 * Does not change facing if the target is null or change too small.
	 * @param	target can be null
	 */
	function faceEntity(target:Entity) {
		if (target == null) {
			return;
		}
		var v = { vx:target.pos.x - pos.x, vy:target.pos.y - pos.y };
		if (v.vx != 0 || v.vy != 0) {
			faceDirection(v.vx, v.vy);		
		}
	}	
}