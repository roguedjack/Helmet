package rj.helmet;
import rj.helmet.Actor.ActorState;
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
	
	//// Common behaviors
	
	/**
	 * Set a simple straight motion towards the player.
	 * @return false if the player is not a valid target (not there, dead, too far)
	 */
	function doMoveStraightAtPlayer():Bool {
		if (world.player == null || world.player.state != ActorState.LIVING) {
			return false;
		}
		var toPlayer = { dx:Math.floor(world.player.pos.x - pos.x), dy:Math.floor(world.player.pos.y - pos.y) };
		if (Math.abs(toPlayer.dx) > aggroRange || Math.abs(toPlayer.dy) > aggroRange) {
			return false;
		}
		motion = {  
			dx: (toPlayer.dx > 0 ? 1 : toPlayer.dx < 0 ? -1 : 0),
			dy: (toPlayer.dy > 0 ? 1 : toPlayer.dy < 0 ? -1 : 0)
		};
		return true;
	}
}