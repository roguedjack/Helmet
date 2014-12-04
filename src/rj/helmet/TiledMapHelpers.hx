package rj.helmet;
import hxd.res.TiledMap.TiledMapData;
import hxd.res.TiledMap.TiledMapLayer;
import rj.helmet.Tiles;

/**
 * ...
 * @author roguedjack
 */
class TiledMapHelpers {
	
	public static inline function getFloorLayer(mapData:TiledMapData):TiledMapLayer {
		var l = Lambda.find(mapData.layers, function(l) return l.name == Main.TILED_FLOOR_LAYER_NAME);
		if (l == null) {
			throw "could not find floor layer in tiled map";
		}
		return l;
	}
	
	public static inline function getWallsLayer(mapData:TiledMapData):TiledMapLayer {
		var l = Lambda.find(mapData.layers, function(l) return l.name == Main.TILED_WALLS_LAYER_NAME);
		if (l == null) {
			throw "could not find walls layer in tiled map";
		}
		return l;
	}	
	
	public static inline function getTile(mapData:TiledMapData, layer:TiledMapLayer, tx:Int, ty:Int):Int {
		// TODO -- check out of bounds
		return layer.data[tx + ty * mapData.width];
	}

	private function new() {
		
	}
	
}