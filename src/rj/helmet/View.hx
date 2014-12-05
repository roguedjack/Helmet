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
	
	private static inline var SCALE = 2.0;
	
	var tilesSetBmp:BitmapData;
	var mapLayers:Layers;
	var floorLayer:Sprite;
	var floorBmp:Bitmap;	
	var wallsLayer:Sprite;
	var wallsBmp:Bitmap;			
	var projectilesLayer:Sprite;	
	var actorsLayer:Sprite;
	var itemsLayer:Sprite;
	public var followTarget(default,set):Entity;

	public function new(?parent:Sprite) {
		super(parent);

		tilesSetBmp = Res.gfx.tiles.toBitmap(); // cache
		
		mapLayers = new Layers(this);
		mapLayers.setScale(SCALE);
		floorLayer = new Sprite();
		floorBmp = new Bitmap(null, floorLayer);
		itemsLayer = new Sprite();
		projectilesLayer = new Sprite();
		wallsLayer = new Sprite();
		wallsBmp = new Bitmap(null, wallsLayer);
		actorsLayer = new Sprite();
		mapLayers.addChildAt(floorLayer, 0);
		mapLayers.addChildAt(itemsLayer, 1);
		mapLayers.addChildAt(projectilesLayer, 2);		
		mapLayers.addChildAt(wallsLayer, 3);
		mapLayers.addChildAt(actorsLayer, 4);
	}
	
	function set_followTarget(e) {
		return followTarget = e;
	}
	
	function centerOn(x:Float, y:Float) {
		mapLayers.setPos( -SCALE*x + 0.5*Main.WIDTH, -SCALE*y + 0.5*Main.HEIGHT);
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
		getEntityLayer(e).addChild(e.sprite);
	}	
	
	public function removeEntitySprite(e:Entity) {
		e.sprite.remove();
	}
	
	public function redrawLevelTilesBmp(mapData:TiledMapData) {
		var floorMap = TiledMapHelpers.getFloorLayer(mapData);
		var wallsMap = TiledMapHelpers.getWallsLayer(mapData);
		
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
			var tile = TiledMapHelpers.getTile(mapData, layer, tx, ty);
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
		floorBmp.tile = Tile.fromBitmap(floorCanvas);
		floorCanvas.dispose();		
		wallsBmp.tile = Tile.fromBitmap(wallsCanvas);
		wallsCanvas.dispose();
	}
	
	public function update(elapsed:Float) {
		// autofollow player or start point.
		if (followTarget == null) {
			followTarget = Main.Instance.world.player;
			if (followTarget == null) {
				followTarget = Main.Instance.world.startPoint;
			}
		}
		
		// center on follow target
		if (followTarget != null && followTarget.pos != null) {
			centerOn(followTarget.pos.x, followTarget.pos.y);
		}
	}
}