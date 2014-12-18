package rj.helmet.entities;
import rj.helmet.dat.GameData;
import rj.helmet.Entity.EntityType;
import rj.helmet.fx.HoverEntityFx;
import rj.helmet.Item;
import rj.helmet.Item.ItemType;

/**
 * ...
 * @author roguedjack
 */
class KeyItem extends Item {

	public function new() {
		super(ItemType.KEY, GameData.KeyItem);
	}
	
	override public function spawn(x:Float, y:Float) {
		super.spawn(x, y);
		startFx(new HoverEntityFx());
	}
	
}