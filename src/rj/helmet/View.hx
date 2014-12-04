package rj.helmet;
import h2d.Bitmap;
import h2d.CachedBitmap;
import h2d.Layers;
import h2d.Sprite;
import h2d.Tile;
import hxd.BitmapData;
import hxd.Res;
import hxd.res.TiledMap.TiledMapData;
import hxd.res.TiledMap.TiledMapLayer;
import hxd.Timer;
import rj.helmet.Entity.EntityType;

/**
 * ...
 * @author roguedjack
 */
class View extends Sprite {
	
	var tilesSetBmp:BitmapData;
	var layers:Layers;
	var floorLayer:Sprite;
	var floorBmp:Bitmap;	
	var wallsLayer:Sprite;
	var wallsBmp:Bitmap;		
	var projectilesLayer:Sprite;	
	var actorsLayer:Sprite;
	var itemsLayer:Sprite;

	public function new(?parent:Sprite) {
		super(parent);

		tilesSetBmp = Res.gfx.tiles.toBitmap(); // cache
		
		layers = new Layers(this);
		floorLayer = new Sprite();
		itemsLayer = new Sprite();
		projectilesLayer = new Sprite();
		wallsLayer = new Sprite();
		actorsLayer = new Sprite();
		layers.addChildAt(floorLayer, 0);
		layers.addChildAt(itemsLayer, 1);
		layers.addChildAt(projectilesLayer, 2);		
		layers.addChildAt(wallsLayer, 3);
		layers.addChildAt(actorsLayer, 4);
	}
	
	inline function getEntityLayer(e:Entity):Sprite {
		return switch (e.type) {
			case EntityType.EXIT:
				floorLayer;
			case EntityType.ITEM:
				itemsLayer;				
			case EntityType.MONSTER_GENERATOR:
				itemsLayer;
			case EntityType.PLAYER:
				actorsLayer;
			case EntityType.PROJECTILE:
				projectilesLayer;
			case EntityType.MONSTER:
				actorsLayer;
			default:
				actorsLayer;
		}
	}
	
	
	public function addEntitySprite(e:Entity) {
		if (e.sprite == null) {
			return;
		}
		getEntityLayer(e).addChild(e.sprite);
	}	
	
	public function removeEntitySprite(e:Entity) {
		if (e.sprite == null) {
			return;
		}
		e.sprite.remove();
	}
	
	public function redrawLevelTilesBmp(mapData:TiledMapData) {
		var floorMap = Lambda.find(mapData.layers, function(l) return l.name == Main.TILED_FLOOR_LAYER_NAME);
		if (floorMap == null) {
			throw "could not find floor layer in map";
		}
		var wallsMap = Lambda.find(mapData.layers, function(l) return l.name == Main.TILED_WALLS_LAYER_NAME);
		if (wallsMap == null) {
			throw "could not find walls layer in map";
		}		
		
		// draw the tiles				
		var floorCanvas:BitmapData = new BitmapData(mapData.width * Main.TILE_SIZE, mapData.height * Main.TILE_SIZE);		
		var wallsCanvas:BitmapData = new BitmapData(mapData.width * Main.TILE_SIZE, mapData.height * Main.TILE_SIZE);		
		floorCanvas.lock();		
		wallsCanvas.lock();
		inline function tileToSheetXY(t) {
			t--;
			return { x : Main.TILE_SIZE * (t % Main.TILE_SHEET_COLUMNS), y : Main.TILE_SIZE * Std.int(t / Main.TILE_SHEET_ROWS) };
		}		
		inline function drawTile(layer:TiledMapLayer, tx, ty, canvas:BitmapData) {
			var tile = layer.data[ty * mapData.width + tx];
			if (tile == 0) {
				return;
			}
			var src = tileToSheetXY(tile);
			canvas.draw(tx * Main.TILE_SIZE, ty * Main.TILE_SIZE, tilesSetBmp, src.x, src.y, Main.TILE_SIZE, Main.TILE_SIZE);
		}
		for (ty in 0...mapData.height) {
			for (tx in 0...mapData.width) {
				drawTile(floorMap, tx, ty, floorCanvas);
				drawTile(wallsMap, tx, ty, wallsCanvas);
			}
		}				
		wallsCanvas.unlock();
		floorCanvas.unlock();
		// FIXME can't we just lock-draw-unlock the bitmap? detaching & reallocating sucks.
		if (floorBmp != null) {
			floorBmp.remove();
		}
		floorBmp = new Bitmap(Tile.fromBitmap(floorCanvas), floorLayer);		
		floorCanvas.dispose();
		if (wallsBmp != null) {
			wallsBmp.remove();
		}
		wallsBmp = new Bitmap(Tile.fromBitmap(wallsCanvas), wallsLayer);
		wallsCanvas.dispose();
	}
	
	public function update(elapsed:Float) {
	}
}