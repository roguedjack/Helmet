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

/**
 * An entity that can take damage, has a living cycle and may have animations.
 * 
 * @author roguedjack
 */
class Actor extends Entity {
	
	public var state(default, set):ActorState;
	public var health(default, default):Int;
	public var speed(default, default):Float;
	var animator:Anim;
	var anims:Array<Anim>;
	var iCurrentAnim:Int;
	
	public function new(type:EntityType, props) {
		super(type);
		health = props.health;
		speed = props.speed;
		hardCollision = true;
		animator = new Anim();
		anchor.addChild(animator);
		animator.visible = false;
		iCurrentAnim = -1;
		anims = new Array<Anim>();
		isRemoved = false;
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
				remove();
				onDead();
				
		}
		return state;
	}
	
	function onStartSpawning() { }
	function onStartLiving() { }
	function onStartDying() { }
	function onDead() { }

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
	 * Default is to do nothing.
	 * @param	elapsed
	 */
	function updateLiving(elapsed:Float) { }
	
	/**
	 * Update when in dying state. 
	 * Default is to switch to dead state.
	 * @param	elapsed
	 */
	function updateDying(elapsed:Float) { 
		state = ActorState.DEAD;
	}

	function faceDirection(dx:Float, dy:Float) {
		rotation = Math.atan2(dx, -dy);
	}

	/**
	 * Loose health. Switch to dying state if no health left.
	 * Ignore damage if not living.
	 * @param	source entity inflicting the damage -- can be null
	 * @param	dmg
	 */
	public function takeDamage(source:Entity, dmg:Int) {
		if (state != ActorState.LIVING) {
			return;
		}
		health -= dmg;
		if (health <= 0) {
			state = ActorState.DYING;
		}
	}
}