package rj.helmet.entities;

import rj.helmet.dat.GameData;
import rj.helmet.Entity;
import rj.helmet.Projectile;

/**
 * The axe is slow but large and powerful.
 * 
 * @author roguedjack
 */
class AxeProjectile extends Projectile {
		
	public function new(owner:Entity, vx:Float, vy:Float) {
		super(owner, vx, vy, GameData.AxeProjectile);		
	}
}