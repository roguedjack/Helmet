package rj.helmet.entities;

import rj.helmet.dat.GameData;
import rj.helmet.fx.HoverEntityFx;
import rj.helmet.Item;
import rj.helmet.Item.ItemType;

/**
 * ...
 * @author roguedjack
 */
class HealthItem extends Item {
	
	public var health(default, null):Int;

	public function new() {
		super(ItemType.HEALTH, GameData.HealthItem);				
		health = GameData.HealthItem.health;
	}
	
	override public function spawn(x:Float, y:Float) {
		super.spawn(x, y);
		startFx(new HoverEntityFx());
	}
}