package rj.helmet;

import h2d.filter.Glow;
import h2d.Tile;
import rj.helmet.Entity.EntityType;
import rj.helmet.fx.HoverEntityFx;

@:enum abstract ItemType(Int) {
	var KEY = 0;
	var TREASURE = 1;
	var HEALTH = 2;
}

/**
 * ...
 * @author roguedjack
 */
class Item extends Entity {	
	
	public var itemType(default, null):ItemType;

	public function new(itemType:ItemType) {
		super(EntityType.ITEM);
		this.itemType = itemType;
		canCollide  = true;		
	}
}