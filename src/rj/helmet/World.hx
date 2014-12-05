package rj.helmet;
import h2d.col.Bounds;
import hxd.Res;
import hxd.res.TiledMap;
import rj.helmet.entities.ExitEntity;
import rj.helmet.entities.PlayerActor;
import rj.helmet.entities.StartEntity;
import rj.helmet.Entity.EntityType;

/**
 * ...
 * @author roguedjack
 */
class World {
	
	var game:Main;
	public var mapData(default,null):TiledMapData;
	public var time(default, null):Float;
	public var player(default, null):Entity;
	public var startPoint(default, null):Entity;	
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
		var entitiesMap = TiledMapHelpers.getEntitiesLayer(mapData);

		// walls
		for (ty in 0...mapData.height) {
			for (tx in 0...mapData.width) {
				isWall[tileIndex(tx, ty)] = TiledMapHelpers.getTile(mapData, wallsMap, tx, ty) != 0;
			}
		}
		
		// entities
		for (o in entitiesMap.objects) {
			var e:Entity = null;
			switch (o.type) {
				case Main.TILEDOBJ_EXIT:
					e = new ExitEntity();
				case Main.TILEDOBJ_START:
					e = new StartEntity();
			}
			if (e == null) {
				throw "unknown entity type " + o.type+" at " + o.x+','+o.y;
			}
			//trace("spawning " + e+" at " + o.x + ',' + o.y);
			spawnEntity(e, o.x, o.y);
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
		return { tx:Math.floor(x / Main.TILE_SIZE), ty:Math.floor(y / Main.TILE_SIZE) };
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
		switch (e.type) {
			case EntityType.START:
				startPoint = e;
			case EntityType.PLAYER:
				player = e;
			default:
				// nop
		}
	}

	public function checkWorldCollision(colBox:Bounds, x:Float, y:Float):{ tl:Int, tr:Int, tu:Int, td:Int, colUL:Bool, colUR:Bool, colDL:Bool, colDR:Bool } {
		var tUL = toTilePos(x + colBox.xMin, y + colBox.yMin);
		var tDR = toTilePos(x + colBox.xMax - 1, y + colBox.yMax - 1);
		return {
			tl:tUL.tx,
			tr:tDR.tx,
			tu:tUL.ty,
			td:tDR.ty,
			colUL:isBlockingAt(tUL.tx, tUL.ty),
			colUR:isBlockingAt(tDR.tx, tUL.ty),
			colDL:isBlockingAt(tUL.tx, tDR.ty),
			colDR:isBlockingAt(tDR.tx, tDR.ty)
		};
	}
	
	public function checkEntitiesCollision(colBox:Bounds, x:Float, y:Float, ignore:Array<Entity>=null):Array<Entity> {
		var bounds = Bounds.fromValues(x+colBox.xMin, y+colBox.yMin, colBox.width, colBox.height);
		var colliders:Array<Entity> = [];
		for (other in entities) {
			if (!other.canCollide) {
				continue;
			}
			if (ignore != null && ignore.indexOf(other) != -1) {
				continue;
			}
			if (other.bounds.collide(bounds)) {
				colliders.push(other);
			}
		}
		return colliders;
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
		
		// do removals.
		var removal;
		while ((removal = entitiesToRemove.pop()) != null) {
			entities.remove(removal);
		}
	}
}