package rj.helmet;
import h2d.Bitmap;
import h2d.CachedBitmap;
import h2d.Layers;
import h2d.Sprite;
import h2d.Tile;
import hxd.BitmapData;
import hxd.Res;
import hxd.res.TiledMap.TiledMapData;
import hxd.Timer;

/**
 * ...
 * @author roguedjack
 */
class View extends Sprite {
	
	var tilesSetBmp:BitmapData;
	var layers:Layers;
	var tilesLayer:Sprite;
	var tilesBmp:Bitmap;	
	var entitiesLayer:Sprite;

	public function new(?parent:Sprite) {
		super(parent);

		tilesSetBmp = Res.gfx.tiles.toBitmap(); // cache
		
		layers = new Layers(this);
		tilesLayer = new Sprite();
		entitiesLayer = new Sprite();
		layers.addChildAt(tilesLayer, 0);
		layers.addChildAt(entitiesLayer, 1);
	}
	
	
	public function addEntitySprite(s:Sprite) {
		if (s == null) {
			return;
		}
		// TODO layers: projectiles -> tiles -> actors -> items
		entitiesLayer.addChild(s);
	}	
	
	public function removeEntitySprite(s:Sprite) {
		if (s == null) {
			return;
		}
		s.remove();
	}
	
	public function redrawLevelTilesBmp(mapData:TiledMapData) {
		var tileMap = Lambda.find(mapData.layers, function(l) return l.name == Main.TILED_TILE_LAYER_NAME);
		if (tileMap == null) {
			throw "could not find tile layer in map";
		}
		
		// draw the tiles
		var canvas:BitmapData = new BitmapData(mapData.width * Main.TILE_SIZE, mapData.height * Main.TILE_SIZE);		
		canvas.lock();		
		for (ty in 0...mapData.height) {
			var y = ty * Main.TILE_SIZE;
			for (tx in 0...mapData.width) {
				var tile = tileMap.data[ty * mapData.width + tx] - 1;  // tiledmap tile numbering starts at 1
				var srcY = Main.TILE_SIZE * Std.int(tile / Main.TILE_SHEET_ROWS);
				var srcX = Main.TILE_SIZE * (tile % Main.TILE_SHEET_COLUMNS);
				canvas.draw(tx*Main.TILE_SIZE, y, tilesSetBmp, srcX, srcY, Main.TILE_SIZE, Main.TILE_SIZE);
			}
		}				
		canvas.unlock();
		// FIXME can't we just lock-draw-unlock the bitmap? detaching & reallocating sucks.
		if (tilesBmp != null) {
			tilesBmp.remove();
		}
		tilesBmp = new Bitmap(Tile.fromBitmap(canvas), tilesLayer);
		canvas.dispose();
	}
	
	public function update(elapsed:Float) {
	}
}