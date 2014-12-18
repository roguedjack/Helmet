package rj.helmet.entities;
import rj.helmet.dat.GameData;
import rj.helmet.Entity.EntityType;
import rj.helmet.Item;
import rj.helmet.Item.ItemType;

/**
 * ...
 * @author roguedjack
 */
class TreasureItem extends Item {
	
	public var score(default, null):Int;

	public function new() {
		super(ItemType.TREASURE, GameData.TreasureItem);
		score = GameData.TreasureItem.score;
		hardCollision = true;
	}
	
}