package rj.helmet.entities;

import h2d.Tile;
import rj.helmet.Attachement;
import rj.helmet.Entity;
import rj.helmet.Entity.EntityType;

/**
 * ...
 * @author roguedjack
 */
class ShieldAttachement extends Attachement {

	public function new(owner:Entity, xAnchor:Float, yAnchor:Float, gfx:Tile, colbox:Array<Int>) {
		super(owner, xAnchor, yAnchor);
		setImage(gfx);
		setCollisionBox(colbox[0], colbox[1], colbox[2], colbox[3]);		
	}
	
	/**
	 * Does not collide with owner projectiles.
	 * @param	other
	 * @return
	 */
	override function canCollideWith(other:Entity):Bool {
		if (other.type == EntityType.PROJECTILE && 	cast(other, Projectile).owner == owner) {
			return false;
		}
		return super.canCollideWith(other);
	}

}