package rj.helmet;

import h2d.filter.Glow;
import h2d.Tile;
import rj.helmet.Entity.EntityType;
import rj.helmet.fx.HoverEntityFx;

@:enum abstract ItemType(Int) {
	var KEY = 0;
	var TREASURE = 1;
	var HEALTH = 2;
	var SPEED_BONUS = 3;
	var FIRERATE_BONUS = 4;
}

/**
 * ...
 * @author roguedjack
 */
class Item extends Entity {	
	
	public var itemType(default, null):ItemType;

	public function new(itemType:ItemType, data) {
		super(EntityType.ITEM);
		this.itemType = itemType;
		canCollide  = true;		
		setImage(Gfx.entities[data.gfx]);
		setCollisionBox(data.colbox[0], data.colbox[1], data.colbox[2], data.colbox[3]);		
	}
}