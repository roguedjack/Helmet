package rj.helmet.entities ;

import h2d.col.Bounds;
import hxd.Res;
import rj.helmet.dat.GameData;
import rj.helmet.Entity.EntityType;

/**
 * ...
 * @author roguedjack
 */
class ExitEntity extends Entity {
	
	public function new() {
		super(EntityType.EXIT);		
		setImage(Gfx.entities[GameData.Exit.gfx]);
		setCollisionBox(GameData.Exit.colbox[0], GameData.Exit.colbox[1], GameData.Exit.colbox[2], GameData.Exit.colbox[3]);
		canCollide = true;
	}
	
}