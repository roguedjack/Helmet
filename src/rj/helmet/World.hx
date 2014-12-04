package rj.helmet;
import hxd.Res;
import hxd.res.TiledMap;
import rj.helmet.Entity.EntityType;

/**
 * ...
 * @author roguedjack
 */
class World {
	
	var game:Main;
	public var mapData(default,null):TiledMapData;
	public var time(default,null):Float;
	var entities:Array<Entity>;
	var entitiesToSpawn:Array<{se:Entity,sx:Float,sy:Float}>;	
	var entitiesToRemove:Array<Entity>;
	var isWall:Array<Bool>;

	public function new(game:Main) {
		this.game = game;
		clearLevel();
	}
	
	public function loadLevel(tiledmap:TiledMap) {
		clearLevel();
		mapData = tiledmap.toMap();
		parseLevelData();
	}
	
	function clearLevel() {
		time = 0;
		entities = [];
		entitiesToRemove = [];
		entitiesToSpawn = [];
		isWall = [];
	}
	
	inline function tileIndex(tx:Int, ty:Int):Int {
		return tx + ty * mapData.width;
	}
	
	function parseLevelData() {		
		var wallsMap = TiledMapHelpers.getWallsLayer(mapData);
		
		for (ty in 0...mapData.height) {
			for (tx in 0...mapData.width) {
				isWall[tileIndex(tx, ty)] = TiledMapHelpers.getTile(mapData, wallsMap, tx, ty) != 0;
				// TODO --- entities: start/exit, monsters generators, items.
			}
		}
	}
	
	public function isInBounds(tx:Int, ty:Int):Bool {
		return tx >= 0 && tx < mapData.width && ty >= 0 && ty < mapData.height;
	}
	
	/**
	 * Check if out of bounds or blocked by a wall.
	 * @param	tx
	 * @param	ty
	 * @return
	 */
	public function isBlockingAt(tx:Int, ty:Int):Bool {
		return !isInBounds(tx,ty) || isWall[tileIndex(tx, ty)];
	}
	
	public inline function toTilePos(x:Float, y:Float): { tx:Int, ty:Int } {
		return { tx:Std.int(x / Main.TILE_SIZE), ty:Std.int(y / Main.TILE_SIZE) };
	}
	
	/**
	 * Check if position is out of bounds or blocked by a wall.
	 * @param	x
	 * @param	y
	 * @return
	 */
	public inline function isBlocking(x:Float, y:Float):Bool {
		var t = toTilePos(x, y);
		return isBlockingAt(t.tx, t.ty);
	}
	
	public function removeEntity(e:Entity) {
		entitiesToRemove.push(e);
	}
	
	public function spawnEntity(e:Entity, x:Float, y:Float) {
		entitiesToSpawn.push( { se:e, sx:x, sy:y } );
	}

	public function update(elapsed:Float) {
		time += elapsed;
		
		// do spawns.
		var spawn;
		while ((spawn = entitiesToSpawn.pop()) != null) {
			entities.push(spawn.se);
			spawn.se.spawn(spawn.sx, spawn.sy);
		}		
		
		// update entities.
		for (e in entities) {
			e.update(elapsed);
		}
		
		// find & resolve entities collisions.
		var n = entities.length;
		for (i in 0...n) {
			var e_i = entities[i];
			if (e_i.canCollide) {
				for (j in i + 1...n) {
					var e_j = entities[j];
					if (e_j.canCollide && e_i.checkCollisionWith(e_j)) {
						e_i.onCollisionWith(e_j);
						e_j.onCollisionWith(e_i);
						// stop checking e_i if collision now disabled
						if (!e_i.canCollide) {  
							break;
						}
					}
				}
			}
		}
		
		// do removals.
		var removal;
		while ((removal = entitiesToRemove.pop()) != null) {
			entities.remove(removal);
		}
	}
}