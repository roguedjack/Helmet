package rj.helmet;
import h2d.Anim;
import h3d.Vector;
import haxe.EnumFlags;
import rj.helmet.Entity.EntityType;

@:enum abstract ActorState(Int) {
	var LIMBO = 0;
	var SPAWNING = 1;
	var LIVING = 2;
	var DYING = 3;
	var DEAD = 4;
}

enum ColFlags {
	COL_LEFT;
	COL_RIGHT;
	COL_UP;
	COL_DOWN;
}

/**
 * An entity than can move and collide, may have an animation, a behavior and a living cycle.
 * @author roguedjack
 */
class Actor extends Entity {
	
	public var state(default, set):ActorState;
	public var motion(default, set): { dx:Float, dy:Float };
	var props: {
		speed: Float
	};
	var animator:Anim;
	var anims:Array<Anim>;
	var iCurrentAnim:Int;
	
	public function new(type:EntityType, props) {
		super(type);
		this.props = props;
		hardCollision = true;
		animator = new Anim();
		anchor.addChild(animator);
		animator.visible = false;
		iCurrentAnim = -1;
		anims = new Array<Anim>();
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

	function set_motion(m: { dx:Float, dy:Float } ) {
		/* normalized -- unwanted friction artefact when sliding along walls
		var l = Math.sqrt(m.dx * m.dx + m.dy * m.dy);
		if (l == 0) {
			motion = { dx:0, dy:0 };
		} else {
			motion = { dx:m.dx/l, dy:m.dy/l };
		} 
		return motion;*/
		return motion = m;
	}	
			
	function addAnim(i:Int, a:Anim) {
		anims[i] = a;
	}
	
	function playAnim(i:Int) {
		if (iCurrentAnim == i) {
			return;
		}
		iCurrentAnim = i;
		animator.speed = anims[i].speed;		
		animator.play(anims[i].frames);
	}
	
	override public function spawn(x:Float, y:Float) {
		super.spawn(x, y);
		motion = { dx:0, dy:0 };
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
		updateAnim(elapsed);		
	}
	
	function updateAnim(elapsed:Float) {
		if (animator == null || iCurrentAnim == -1) {
			return;
		}
		setImage(animator.getFrame());
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
	 * Default is to check & resolve entities and world collision.
	 * @param	elapsed
	 * @see checkEntitiesCollision
	 * @see checkWorldCollision
	 */
	function updatePos(elapsed:Float) {
		// compute frame movement
		var m = props.speed * elapsed;
		var move = { mx:m*motion.dx, my:m*motion.dy };
		var newx = pos.x + move.mx, newy = pos.y + move.my;		

		// check for entity collision.
		// prevent movement if hard collision.
		if (checkEntitiesCollision(elapsed, newx, newy)) {
			return;
		}
		
		// check for world collision.				
		pos = checkWorldCollision(elapsed, newx, newy);
	}
	
	/**
	 * Check if we would collide with entities and notifify collisions.
	 * @param	newx
	 * @param	newy
	 * @param	ignore
	 * @return true if collided with an hard collision entity
	 * @see onCollisionWith
	 */
	function checkEntitiesCollision(elapsed:Float, newx:Float, newy:Float):Bool {
		var colliders = world.checkEntitiesCollision(colBox, newx, newy, function(e) { return canCollideWith(e);} );
		var blocked = false;
		if (colliders != null) {
			for (other in colliders) {
				if (other.hardCollision) {
					blocked = true;
				}
				onCollisionWith(elapsed, other);
			}
		}
		return blocked;
	}
	
	/**
	 * Check if we would collide with the world and notify collisions.
	 * @param	newx
	 * @param	newy
	 * @return the corrected position to prevent world collision.
	 * @see onWorldCollision
	 */
	function checkWorldCollision(elapsed:Float, newx:Float, newy:Float):{x:Float,y:Float} {
		// slide along non colliding axis and align with collided walls.
		var colFlags:EnumFlags<ColFlags> = new EnumFlags<ColFlags>();
		if (motion.dx != 0) {
			var col = world.checkWorldCollision(colBox, newx, pos.y);		
			if (motion.dx < 0) {
				if (col.colDL || col.colUL) {
					newx = (col.tl + 1) * Main.TILE_SIZE - colBox.xMin;
					colFlags.set(COL_LEFT);
				}
			} else {
				if (col.colDR || col.colUR) {
					newx = col.tr * Main.TILE_SIZE - colBox.xMax;
					colFlags.set(COL_RIGHT);
				}			
			}
		}
		if (motion.dy != 0) {
			var col = world.checkWorldCollision(colBox, newx, newy);		
			if (motion.dy < 0) {
				if (col.colUL || col.colUR) {
					newy = (col.tu + 1) * Main.TILE_SIZE - colBox.yMin;
					colFlags.set(COL_UP);
				}
			} else {
				if (col.colDL || col.colDR) {
					newy = col.td * Main.TILE_SIZE - colBox.yMax;
					colFlags.set(COL_DOWN);
				}			
			}
		}				
		
		if (colFlags.toInt() != 0) {
			onWorldCollision(elapsed, colFlags);
		}
		
		return { x:newx, y:newy };
	}

	/**
	 * We have just collided with another entity while attempting to move.
	 * Default is to do nothing.
	 * @param	other
	 */
	function onCollisionWith(elapsed:Float, other:Entity) { }
	
	/**
	 * We have just collided with the world while attempting to move.
	 * Default is to do nothing.
	 * @param	colFlags direction(s) of collision.
	 */
	function onWorldCollision(elapsed:Float, colFlags:EnumFlags<ColFlags>) { }

	function faceDirection(dx:Float, dy:Float) {
		rotation = Math.atan2(dx, -dy);
	}
}