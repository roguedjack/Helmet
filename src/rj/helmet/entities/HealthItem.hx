package rj.helmet.entities;

import rj.helmet.fx.HoverEntityFx;
import rj.helmet.Item;
import rj.helmet.Item.ItemType;

/**
 * ...
 * @author roguedjack
 */
class HealthItem extends Item {
	
	public static inline var HEALTH = 100;

	public function new() {
		super(ItemType.HEALTH);		
		setImage(Gfx.entities[58]);
		setCollisionBox(8, 8, 16, 16);
	}
	
	override public function spawn(x:Float, y:Float) {
		super.spawn(x, y);
		startFx(new HoverEntityFx());
	}
}