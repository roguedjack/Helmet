package rj.helmet;

import h2d.Tile;
import rj.helmet.Entity.EntityType;

@:enum abstract ItemType(Int) {
	var KEY = 0;
}

/**
 * ...
 * @author roguedjack
 */
class Item extends Entity {
	
	public var itemType(default, null):ItemType;

	public function new(itemType:ItemType, img:Tile) {
		super(EntityType.ITEM);
		this.itemType = itemType;
		canCollide  = true;		
		setImage(img);
		setCollisionBox(8, 8, 16, 16);
	}
	
}