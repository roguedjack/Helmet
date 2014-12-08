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
	var timer:Float;
	var aggroRange:Float;

	/**
	 * 
	 * @param	monsterClass constructor must be parameterless.
	 * @param	tile
	 * @param	spawnCooldown delay between monster spawns
	 */
	public function new(monsterClass:Class<Monster>, tile:Tile, spawnCooldown:Float=1, aggroRange:Float=256) {
		super(EntityType.MONSTER_GENERATOR);
		this.monsterClass = monsterClass;
		this.spawnCooldown = spawnCooldown;
		this.aggroRange = aggroRange;
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
		if (timer >= spawnCooldown && distanceToPlayer() <= aggroRange) {
			trySpawningMonster();
			timer -= spawnCooldown;  // cooldown even if could not spawning
		}
	}
	
	inline function distanceToPlayer():Float {
		var toPlayer = { dx:Math.round(world.player.pos.x - pos.x), dy:Math.round(world.player.pos.y - pos.y) };
		return Math.sqrt(toPlayer.dx * toPlayer.dx + toPlayer.dy * toPlayer.dy);
	}
	
	function trySpawningMonster():Bool {
		// try to spawn monster in a free adjacent tile.
		var t = world.toTilePos(pos.x, pos.y);
		t.tx += 1 - Std.random(3);
		t.ty += 1 - Std.random(3);
		if (world.isBlockingAt(t.tx, t.ty)) {
			return false;
		}
		tmpColliders.splice(0, tmpColliders.length);
		world.listEntitiesIn(Bounds.fromValues(t.tx * Main.TILE_SIZE,  t.ty * Main.TILE_SIZE, Main.TILE_SIZE, Main.TILE_SIZE), tmpColliders);
		if (tmpColliders.length != 0) {
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