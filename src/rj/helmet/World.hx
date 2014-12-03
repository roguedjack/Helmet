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
	var actorsList:Array<Actor>;	

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
	}
	
	function parseLevelData() {		
	}
	
	public function removeEntity(e:Entity) {
		entitiesToRemove.push(e);
	}
	
	public function spawnEntity(e:Entity, x:Float, y:Float) {
		entitiesToSpawn.push( { se:e, sx:x, sy:y } );
	}

	public function update(elapsed:Float) {
		time += elapsed;
		
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

		// do spawns.
		var spawn;
		while ((spawn = entitiesToSpawn.pop()) != null) {
			entities.push(spawn.se);
			var actor = cast(spawn.se, Actor);
			if (actor != null) {
				actorsList.push(actor);
			}
			spawn.se.spawn(spawn.sx, spawn.sy);
		}
		
		// do removals.
		var removal;
		while ((removal = entitiesToRemove.pop()) != null) {
			entities.remove(removal);
			var actor = cast(removal, Actor);
			if (actor != null) {
				actorsList.remove(actor);
			}
		}
	}
}