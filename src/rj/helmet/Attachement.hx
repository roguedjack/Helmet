package rj.helmet;

import format.swf.Data.FontLayoutData;
import rj.helmet.Entity;
import rj.helmet.Entity.EntityType;

/**
 * ...
 * @author roguedjack
 */
class Attachement extends Entity {
	
	public var owner(default, null):Entity;
	public var xAnchor(default, default):Float;
	public var yAnchor(default, default):Float;

	/**
	 * 
	 * @param	owner
	 * @param	xAnchor x position relative to owner when rotation = 0
	 * @param	yAnchor y position relative to owner when rotation = 0
	 */
	public function new(owner:Entity, xAnchor:Float, yAnchor:Float) {
		super(EntityType.ATTACHEMENT);
		this.owner = owner;
		this.xAnchor = xAnchor;
		this.yAnchor = yAnchor;
		canCollide = true;
		hardCollision = true;
	}
	
	/**
	 * Does not collide with owner.
	 * @param	other
	 * @return
	 */
	override function canCollideWith(other:Entity):Bool {
		if (other == owner) {
			return false;
		}
		return super.canCollideWith(other);
	}

	/**
	 * Follows the owner.
	 * @param	elapsed
	 */
	override public function update(elapsed:Float) {
		super.update(elapsed);

		rotation = owner.rotation;
		var cos = Math.cos(rotation);
		var sin = Math.sin(rotation);
		var xoffset = xAnchor * cos - yAnchor * sin;
		var yoffset = xAnchor * sin + yAnchor * cos;
		pos = { x:owner.pos.x + xoffset, y:owner.pos.y + yoffset };
	}
}