package rj.helmet.entities;

import h2d.filter.Glow;
import rj.helmet.dat.GameData;
import rj.helmet.fx.HoverEntityFx;
import rj.helmet.Item;
import rj.helmet.Item.ItemType;

/**
 * ...
 * @author roguedjack
 */
class BonusItem extends Item {
	
	public var value(default, null):Float;
	public var duration(default, null):Float;
	public var glowColor(default, null):Int;	

	public function new(itemType:ItemType, itemData, bonusData) {
		super(itemType, itemData);		
		value = bonusData.value;
		duration = bonusData.duration;
		glowColor = Std.parseInt(bonusData.glowColor);		
	}
	
	override public function spawn(x:Float, y:Float) {
		super.spawn(x, y);
		startFx(new HoverEntityFx());
		bitmap.filters.push(new Glow(glowColor, 1, 1, 4));		
	}
	
	public function apply(p:PlayerActor) {
		switch (itemType) {
			case ItemType.SPEED_BONUS:
				p.speed += value;
			default:
				throw "not a bonus!";
		}
	}
	
	public function unapply(p:PlayerActor) {
		switch (itemType) {
			case ItemType.SPEED_BONUS:
				p.speed -= value;
			default:
				throw "not a bonus!";
		}		
	}
}