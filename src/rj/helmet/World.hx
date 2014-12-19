package rj.helmet;
import h2d.col.Bounds;
import hxd.Res;
import hxd.res.TiledMap;
import rj.helmet.dat.GameData;
import rj.helmet.entities.BonusItem;
import rj.helmet.entities.DebrisParticle;
import rj.helmet.entities.DemonMonster;
import rj.helmet.entities.DestructibleWall;
import rj.helmet.entities.DoorEntity;
import rj.helmet.entities.ExitEntity;
import rj.helmet.entities.HealthItem;
import rj.helmet.entities.KeyItem;
import rj.helmet.entities.MovingWall;
import rj.helmet.entities.PlayerActor;
import rj.helmet.entities.GhostMonster;
import rj.helmet.entities.StartEntity;
import rj.helmet.entities.TreasureItem;
import rj.helmet.Entity.EntityType;
import rj.helmet.Item.ItemType;

/**
 * ...
 * @author roguedjack
 */
class World {
	
	var game:Main;
	public var mapData(default, null):TiledMapData;
	public var time(default, null):Float;
	public var elapsed(default, null):Float;
	public var player(default, null):PlayerActor;
	public var startPoint(default, null):Entity;	
	public var countEntities(get, never):Int;
	var entities:Array<Entity>;
	var entitiesToSpawn:Array<{se:Entity,sx:Float,sy:Float}>;	
	var entitiesToRemove:Array<Entity>;
	var isWall:Array<Bool>;
	#if COLLISION_GRID
	var collisionGrid:CollisionGrid;
	#end

	public function new(game:Main) {
		this.game = game;
		clearLevel();
	
	}
		
	function get_countEntities() {
		return entities.length;
	}
	
	public function loadMap(tiledmap:TiledMap) {
		clearLevel();
		mapData = tiledmap.toMap();
		#if COLLISION_GRID
		collisionGrid = new CollisionGrid(mapData.width, mapData.height);
		#end
		parseMapData();
	}
	
	function clearLevel() {
		time = elapsed = 0;
		entities = [];
		entitiesToRemove = [];
		entitiesToSpawn = [];
		isWall = [];
		player = null;
	}
	
	inline function tileIndex(tx:Int, ty:Int):Int {
		return tx + ty * mapData.width;
	}
	
	function parseMapData() {		
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
				case Main.TILEDOBJ_GEN_GHOST:
					e = new MonsterGenerator(GhostMonster, new ParticleGenerator(DebrisParticle, [0x999999]), GameData.GhostGenerator);
				case Main.TILEDOBJ_GEN_DEMON:
					e = new MonsterGenerator(DemonMonster, new ParticleGenerator(DebrisParticle, [0x999999]), GameData.DemonGenerator);	
				case Main.TILEDOBJ_HDOOR:
					e = new DoorEntity(o.name, false);
				case Main.TILEDOBJ_VDOOR:
					e = new DoorEntity(o.name, true);
				case Main.TILEDOBJ_KEY:
					e = new KeyItem();					
				case Main.TILEDOBJ_TREASURE:
					e = new TreasureItem();
				case Main.TILEDOBJ_HEALTH:
					e = new HealthItem();
				case Main.TILEDOBJ_HWALL:
					e = new MovingWall(false, GameData.MovingWall);
				case Main.TILEDOBJ_VWALL:
					e = new MovingWall(true, GameData.MovingWall);					
				case Main.TILEDOBJ_DWALL:
					e = new DestructibleWall(GameData.DestructibleWall);
				case Main.TILEDOBJ_SPEEDBONUS:
					e = new BonusItem(ItemType.SPEED_BONUS, GameData.SpeedBonus, GameData.SpeedBonus);
			}
			if (e == null) {
				throw "unknown entity type " + o.type+" at " + o.x+','+o.y;
			}
			
			// force coordinates to grid
			o.x = Main.TILE_SIZE * Math.floor(o.x / Main.TILE_SIZE);
			o.y = Main.TILE_SIZE * Math.floor(o.y / Main.TILE_SIZE);
			
			// die if another entity is already there!
			for (other in entitiesToSpawn) {
				if (other.sx == o.x && other.sy == o.y) {
					throw "map parsing: entities "+o.name+" and another one on the same tile -- fix your map :-)";
				}
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
		#if COLLISION_GRID
		collisionGrid.remove(e);
		#end
	}
	
	public function spawnEntity(e:Entity, x:Float, y:Float) {
		entitiesToSpawn.push( { se:e, sx:x, sy:y } );
		switch (e.type) {
			case EntityType.START:
				startPoint = e;
			case EntityType.PLAYER:
				player = cast(e, PlayerActor);
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

	public function listEntitiesIn(bounds:Bounds, ?out:Array<Entity>):Array<Entity> {
		if (out == null) {
			out = new Array<Entity>();			
		}
		#if COLLISION_GRID
		var nearList = collisionGrid.listEntities(bounds);
		for (e in nearList) {
			if (e.bounds.collide(bounds)) {
				out.push(e);
			}
		}
		#else
		for (e in entities) {
			if (e.bounds.collide(bounds)) {
				out.push(e);
			}
		}
		#end
		return out;
	}
		
	public function isFreeForSpawning(bounds:Bounds):Bool {
		#if COLLISION_GRID
		var nearList = collisionGrid.listEntities(bounds);
		for (e in nearList) {
			if (!e.isRemoved && e.bounds.collide(bounds)) {
				return false;
			}
		}
		#else
		for (e in entities) {
			if (!e.isRemoved && e.bounds.collide(bounds)) {
				return false;
			}
		}
		#end
		var spawnBounds = new Bounds();
		for (e in entitiesToSpawn) {
			spawnBounds.set(e.sx, e.sy, e.se.bounds.width, e.se.bounds.height);
			if (spawnBounds.collide(bounds)) {
				return false;
			}
		}				
		return true;
	}
	
	public function filterEntities(predicateFn:Entity->Bool, ?out:Array<Entity>):Array<Entity> {
		if (out == null) {
			out = new Array<Entity>();
		}
		for (e in entities) {
			if (predicateFn(e)) {
				out.push(e);
			}
		}
		return out;
	}
	
	#if COLLISION_GRID
	public function removeFromCollisionGrid(e:Entity) {
		if (e.pos != null) {
			collisionGrid.remove(e);
		}
	}
	
	public function addToCollisionGrid(e:Entity) {
		if (e.pos != null) {
			collisionGrid.add(e);
		}
	}
	#end
	
	public function update(elapsed:Float) {
		this.elapsed = elapsed;
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