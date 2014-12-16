package rj.helmet.entities;

import rj.helmet.dat.GameData;
import rj.helmet.Entity;
import rj.helmet.Projectile;

/**
 * The sword is average.
 * 
 * @author roguedjack
 */
class SwordProjectile extends Projectile {
	
	public function new(owner:Entity, vx:Float, vy:Float) {
		super(owner, vx, vy, GameData.SwordProjectile);		
	}
}