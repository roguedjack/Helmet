package rj.helmet.entities ;

import h2d.col.Bounds;
import hxd.Res;
import rj.helmet.Entity.EntityType;

/**
 * ...
 * @author roguedjack
 */
class ExitEntity extends Entity {
	
	public function new() {
		super(EntityType.EXIT);		
		setImage(Gfx.entities[0]);
		setCollisionBox(8, 8, 16, 16);
		canCollide = true;
	}
	
}