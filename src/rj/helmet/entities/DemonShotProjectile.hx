package rj.helmet.entities;

import rj.helmet.dat.GameData;
import rj.helmet.Entity;
import rj.helmet.Projectile;

/**
 * ...
 * @author roguedjack
 */
class DemonShotProjectile extends MonsterProjectile {
	
	public function new(owner:Entity, vx:Float, vy:Float) {
		super(owner, vx, vy, GameData.DemonShotProjectile);
	}

}