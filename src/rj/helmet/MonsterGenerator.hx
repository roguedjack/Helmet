package rj.helmet;

import h2d.col.Bounds;
import h2d.Tile;
import rj.helmet.Entity.EntityType;

/**
 * ...
 * @author roguedjack
 */
class MonsterGenerator extends Entity {
	
	public var monsterClass(default, null):Class<Monster>;
	public var spawnCooldown(default, default):Float;
	private static var TILE_BOUNDS = Bounds.fromValues(0, 0, Main.TILE_SIZE, Main.TILE_SIZE);
	var timer:Float;

	/**
	 * 
	 * @param	monsterClass constructor must be parameterless.
	 * @param	tile
	 * @param	spawnCooldown delay between monster spawns
	 */
	public function new(monsterClass:Class<Monster>, tile:Tile, spawnCooldown:Float=1) {
		super(EntityType.MONSTER_GENERATOR);
		this.monsterClass = monsterClass;
		this.spawnCooldown = spawnCooldown;
		canCollide  = true;
		hardCollision = true;
		setCollisionBox(8, 8, 16, 16);
		setImage(tile);
	}
	
	override public function spawn(x:Float, y:Float) {
		super.spawn(x, y);
		timer = 0;
	}
	
	override public function update(elapsed:Float) {
		super.update(elapsed);
		timer += elapsed;
		if (timer >= spawnCooldown) {
			trySpawningMonster();
			timer -= spawnCooldown;  // cooldown even if could not spawning
		}
	}
	
	function trySpawningMonster():Bool {
		// try to spawn monster in a free adjacent tile.
		var t = world.toTilePos(pos.x, pos.y);
		t.tx += 1 - Std.random(3);
		t.ty += 1 - Std.random(3);
		if (world.isBlockingAt(t.tx, t.ty)) {
			return false;
		}
		if (world.checkEntitiesCollision(TILE_BOUNDS, t.tx * Main.TILE_SIZE, t.ty * Main.TILE_SIZE, function(e) { return true; } ).length != 0) {
			return false;
		}
		
		// tile is free.
		spawnMonster(t.tx * Main.TILE_SIZE, t.ty * Main.TILE_SIZE);
		return true;
	}
	
	function spawnMonster(x:Float, y:Float) {
		var m:Monster = Type.createInstance(monsterClass, []);
		world.spawnEntity(m, x, y);
	}
}