package rj.helmet;

import rj.helmet.Actor.ActorState;
import rj.helmet.Entity;
import rj.helmet.Entity.EntityType;

/**
 * Triggers when the player stands on it.
 * 
 * @author roguedjack
 */
class Trigger extends Entity {
	
	public var repeatable(default, null):Bool;
	public var delay(default, null):Float;
	var triggerTime:Float;
	var triggered:Bool;

	public function new(delay:Float = 0, repeatable:Bool = false) {		
		super(EntityType.TRIGGER);
		this.repeatable = repeatable;
		this.delay = delay;
		triggerTime = 0;
		canCollide = false;
		isVisible = false;
		setCollisionBox(0, 0, Main.TILE_SIZE, Main.TILE_SIZE);
	}
	
	override public function update(elapsed:Float) {
		super.update(elapsed);
		
		if (triggered) {
			if ((triggerTime -= elapsed) <= 0) {
				fireTrigger();
				if (!repeatable) {
					remove();
				}
			}
		} else {
			if (world.player == null || world.player.state != ActorState.LIVING) {
				return;
			}
			if (world.player.bounds.collide(bounds)) {
				triggerTime = delay;
				triggered = true;
			}
		}
	}
	
	function fireTrigger() { }
}