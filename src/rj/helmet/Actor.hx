package rj.helmet;
import rj.helmet.Entity.EntityType;

@:enum abstract ActorState(Int) {
	var LIMBO = 0;
	var SPAWNING = 1;
	var LIVING = 2;
	var DYING = 3;
	var DEAD = 4;
}

/**
 * ...
 * @author roguedjack
 */
class Actor extends Entity {
	
	public var state(default, set):ActorState;
	public var motion(default,set):{ dx:Float, dy:Float };
	var speed: Float;

	public function new(type:EntityType) {
		super(type);
	}
	
	function set_state(s) {
		if (s == state) {
			return s;
		}
		state = s;
		switch (s) {
			case ActorState.LIMBO:
				canCollide = false;
				isVisible = false;
			case ActorState.SPAWNING:
				canCollide = false;
				isVisible = true;
				onStartSpawning();
			case ActorState.LIVING:
				canCollide = true;
				isVisible = true;
				onStartLiving();
			case ActorState.DYING:
				canCollide = false;
				isVisible = true;
				onStartDying();
			case ActorState.DEAD:
				canCollide = false;
				isVisible = false;
				onDead();
				
		}
		return state;
	}
	
	function onStartSpawning() { }
	function onStartLiving() { }
	function onStartDying() { }
	function onDead() { }

	function set_motion(m:{dx:Float,dy:Float}) {
		var l = Math.sqrt(m.dx * m.dx + m.dy * m.dy);
		if (l == 0) {
			motion = { dx:0, dy:0 };
		} else {
			motion = { dx:m.dx/l, dy:m.dy/l };
		}
		return motion;
	}	
			
	override public function spawn(x:Float, y:Float) {
		super.spawn(x, y);
		state = ActorState.SPAWNING;
	}
	
	override public function update(elapsed:Float) {
		super.update(elapsed);
		switch (state) {
			case ActorState.LIMBO:
				// nop
			case ActorState.SPAWNING:
				updateSpawning(elapsed);
			case ActorState.LIVING:
				updateLiving(elapsed);
			case ActorState.DYING:
				updateDying(elapsed);
			case ActorState.DEAD:
				// nop
		}
	}
	
	/**
	 * Update when in spawning state. 
	 * Default is to switch to living state.
	 * @param	elapsed
	 */
	function updateSpawning(elapsed:Float) { 
		state = ActorState.LIVING;
	}
	
	/**
	 * Update when in living state. 
	 * Default is to updateBehavior and updatePos.
	 * @param	elapsed
	 */
	function updateLiving(elapsed:Float) { 
		updateBehavior(elapsed);
		updatePos(elapsed);
	}
	
	/**
	 * Update when in dying state. 
	 * Default is to switch to dead state.
	 * @param	elapsed
	 */
	function updateDying(elapsed:Float) { 
		state = ActorState.DEAD;
	}
	
	/**
	 * Update behavior when living. 
	 * Default is to do nothing.
	 * @param	elapsed
	 */
	function updateBehavior(elapsed:Float) {
		
	}
	
	/**
	 * Update position when living. 
	 * Default is to move by the current motion*speed, stopping at world collision and dispatching world collision events.
	 * @param	elapsed
	 */
	function updatePos(elapsed:Float) {
		// compute frame movement
		var dx = motion.dx;
		var dy = motion.dy;
		var m = speed * elapsed;
		var mx = m * dx;
		var my = m * dy;
		
		// TODO check world collision
				
		pos = { x:pos.x+mx, y:pos.y+my };
	}
	
	/**
	 * A world collision along an axis has happened when updating position.
	 * Default is to stop the movement on this axis.
	 * @param	mx
	 * @param	my
	 * @return the corrected motion
	 */
	function onWorldCollision(mx:Float, my:Float): { mx:Float, my:Float } {
		return { mx:0, my:0 };
	}
}