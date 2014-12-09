package rj.helmet;
import hxd.Res;
import rj.helmet.Actor.ActorState;
import rj.helmet.Entity;
import rj.helmet.Entity.EntityType;

/**
 * ...
 * @author roguedjack
 */
class Monster extends Actor {
	
	/**
	 * Range below which the monster will be aggressive to the player.
	 */
	public var aggroRange(default, default):Float;

	// FIXME --- make up my mind : use props or simple parameters?
	public function new(props, aggroRange:Float=256) {
		super(EntityType.MONSTER, props);
		canCollide = true;
		hardCollision = true;
		this.aggroRange = aggroRange;
	}
	
	override public function takeDamage(source:Entity, dmg:Int) {
		super.takeDamage(source, dmg);
		if (health > 0) {
			playSfx(Res.sfx.monster_hit);
		}
	}
	
	override function onStartDying() {
		super.onStartDying();
		playSfx(Res.sfx.monster_die);
	}
	
	//// Helpers
	
	function toDir8(vx:Float, vy:Float): { vx:Float, vy:Float } {
		var l = Math.sqrt(vx * vx + vy * vy);
		if (l == 0) {
			return { vx:0, vy:0 };
		}
		vx /= l;
		vy /= l;
		// FIXME --- jerkyness due to comparing non-zero float thresholds?
		vx = (vx < -0.75 ? -1 : vx < -0.25 ? -0.5 : vx > 0.75 ? 1 : vx > 0.25 ? 0.5 : 0);
		vy = (vy < -0.75 ? -1 : vy < -0.25 ? -0.5 : vy > 0.75 ? 1 : vy > 0.25 ? 0.5 : 0);				
		return { vx:vx, vy:vy };
	}
	
	//// Common behaviors
	
	/**
	 * Set a simple straight motion towards the player.
	 * @return the movement
	 */
	function doMoveStraightAtPlayer(elapsed:Float): { vx:Float, vy:Float } {
		var m: { vx:Float, vy:Float } = { vx:0, vy:0 };
		if (world.player == null || world.player.state != ActorState.LIVING) {
			return m;
		}
		var toPlayer = { dx:world.player.pos.x - pos.x, dy:world.player.pos.y - pos.y };
		if (Math.abs(toPlayer.dx) > aggroRange || Math.abs(toPlayer.dy) > aggroRange) {
			return m;
		}
		m = toDir8(toPlayer.dx, toPlayer.dy);
		m.vx *= props.speed * elapsed;
		m.vy *= props.speed * elapsed;
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
		v = toDir8(v.vx, v.vy);
		if (v.vx != 0 || v.vy != 0) {
			faceDirection(v.vx, v.vy);		
		}
	}	
}