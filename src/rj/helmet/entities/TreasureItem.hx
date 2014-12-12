package rj.helmet.entities;
import rj.helmet.Entity.EntityType;
import rj.helmet.Item;
import rj.helmet.Item.ItemType;

/**
 * ...
 * @author roguedjack
 */
class TreasureItem extends Item {
	
	public static inline var SCORE = 500;

	public function new() {
		super(ItemType.TREASURE);
		setImage(Gfx.entities[57]);		
		setCollisionBox(8, 8, 16, 16);
		hardCollision = true;
	}
	
}