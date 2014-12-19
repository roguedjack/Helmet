package rj.helmet.entities;
import h2d.Tile;
import hxd.Res;
import rj.helmet.Damageable;
import rj.helmet.dat.GameData;
import rj.helmet.Entity;
import rj.helmet.ParticleGenerator;

/**
 * ...
 * @author roguedjack
 */
class DestructibleWall extends Entity implements Damageable {
	
	var tiles:Array<Tile>;
	var hits:Int;
	var maxHitPoints:Int;
	var particleGenerator:ParticleGenerator;

	public function new(data) {
		super(EntityType.TRAP);
		tiles = GameData.parseEntityFrames(data.gfx);		
		canCollide = true;
		hardCollision = true;
		maxHitPoints = hits = data.hits;
		setCollisionBox(data.colbox[0], data.colbox[1], data.colbox[2], data.colbox[3]);		
		refreshImage();
		particleGenerator = new ParticleGenerator(DebrisParticle, [Std.parseInt(data.debris.color)], 0.5, 1, 32, 64, data.debris.amount);		
	}
	
	function refreshImage() {
		var hitLevel = (maxHitPoints - hits) / maxHitPoints;
		var hitImage = Math.floor(hitLevel * tiles.length);		
		setImage(tiles[hitImage]);
	}
	
	public function takeDamage(source:Entity, dmg:Int) {
		playSfx(Res.sfx.monster_hit_wav);
		spawnDebris();
		if ((hits -= dmg) <= 0) {
			remove();
			spawnDebris(); // x2 debris when destroyed
		} else {
			refreshImage(); 
		}
	}
	
	function spawnDebris() {
		particleGenerator.emitBatch(bounds);
	}
}