package rj.helmet.entities;

import hxd.Key;
import rj.helmet.Entity;
import rj.helmet.Entity.EntityType;

/**
 * ...
 * @author roguedjack
 */
class StartEntity extends Entity {

	public function new() {
		super(EntityType.START);	
		isVisible = false;
	}
	
	override public function update(elapsed:Float) {
		super.update(elapsed);
		
		// spawn player?
		if (world.player == null) {
			world.spawnEntity(new PlayerActor(), pos.x, pos.y);
		}
	}
}