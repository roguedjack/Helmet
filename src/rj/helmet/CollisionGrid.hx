package rj.helmet;
import h2d.col.Bounds;
import h3d.prim.Grid;
import hxd.res.TiledMap.TiledMapData;

/**
 * ...
 * @author roguedjack
 */
class CollisionGrid {

	var width:Int;
	var height:Int;
	var grid:Array<Array<Entity>>;

	public function new(width:Int, height:Int) {		
		this.width = width;
		this.height = height;
		grid = new Array<Array<Entity>>();
	}
	
	inline function index(x:Int, y:Int):Int {
		return x + y * width;
	}
	
	inline function gridX(x:Float):Int {
		return Math.floor(x / Main.TILE_SIZE);
	}
	
	inline function gridY(y:Float):Int {
		return Math.floor(y / Main.TILE_SIZE);
	}	
	
	inline function isInBounds(x:Int, y:Int):Bool {
		return x >= 0 && x < width && y >= 0 && y < height;
	}
	
	inline function getGridBounds(b:Bounds):Bounds {
		var xMin = gridX(b.xMin - Main.TILE_SIZE);
		var yMin = gridY(b.yMin - Main.TILE_SIZE);
		var width = 1 + gridX(b.width + Main.TILE_SIZE);		
		var height = 1 + gridY(b.height + Main.TILE_SIZE);
		return Bounds.fromValues(xMin, yMin, width, height);
	}
	
	inline function forEachGridCellIn(b:Bounds, fn:Int->Int->Void) {
		var xMin = Math.floor(b.xMin);
		var xMax = 1 + Math.floor(b.xMax);
		var yMin = Math.floor(b.yMin);
		var yMax = 1 + Math.floor(b.yMax);		
		for (x in xMin...xMax) {
			for (y in yMin...yMax) {
				if (isInBounds(x,y)) {
					fn(x, y);
				}
			}
		}
	}
	
	inline function addAt(e:Entity, x:Int, y:Int) {
		var i = index(x, y);
		var list = grid[i];
		if (list == null) {
			grid[i] = list = new Array<Entity>();
		}
		list.push(e);
	}
	
	inline function removeAt(e:Entity, x:Int, y:Int) {
		var list = getAt(x, y);
		if (list != null) {
			list.remove(e);
		}
	}

	/**
	 * 
	 * @param	x
	 * @param	y
	 * @return null if none
	 */
	inline function getAt(x:Int, y:Int):Array<Entity> {
		return isInBounds(x, y) ? grid[index(x, y)] : null;
	}
	
	public function add(e:Entity) {
		var gridBounds = getGridBounds(e.bounds);
		forEachGridCellIn(gridBounds, function(x, y) {
			addAt(e, x, y);
		});
	}
	
	public function remove(e:Entity) {
		var gridBounds = getGridBounds(e.bounds);
		forEachGridCellIn(gridBounds, function(x, y) {
			removeAt(e, x, y);
		});		
	}
	
	public function listEntities(b:Bounds, ?out:Array<Entity>):Array<Entity> {
		if (out == null) {
			out = new Array<Entity>();
		}
		var gridBounds = getGridBounds(b);
		forEachGridCellIn(gridBounds, function(x, y) {
			var atXY = getAt(x, y);
			if (atXY != null) {
				for (e in atXY) {
					if (out.indexOf(e) == -1) {
						out.push(e);
					}
				}
			}
		});
		return out;
	}
}