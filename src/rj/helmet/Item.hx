package rj.helmet;

import h2d.filter.Glow;
import h2d.Tile;
import rj.helmet.Entity.EntityType;
import rj.helmet.fx.HoverEntityFx;

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
	
	override public function spawn(x:Float, y:Float) {
		super.spawn(x, y);
		startFx(new HoverEntityFx());
	}
}