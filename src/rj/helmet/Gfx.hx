package rj.helmet;
import h2d.Tile;
import hxd.Res;

/**
 * ...
 * @author roguedjack
 */
class Gfx {
	
	public static var entities:Array<Tile>;
	
	public static function init() {
		entities = Res.gfx.entities.toTile().grid(Main.TILE_SIZE);
	}

	private function new() {
		
	}
	
}