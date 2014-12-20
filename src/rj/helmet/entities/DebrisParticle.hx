package rj.helmet.entities;
import haxe.EnumFlags;
import h2d.Tile;
import haxe.ds.IntMap;
import rj.helmet.Entity.ColFlags;
import rj.helmet.Particle;

/**
 * A particle that behaves like a debris.
 * Will spin while moving then "land" and fade out.
 * Is not removed when colliding with walls but lands instead.
 * @author roguedjack
 */
class DebrisParticle extends Particle {
	
	public static inline var DRAG = 0.99;
	public static inline var SPIN_FACTOR = 1.0;
	public static inline var LAND_TIME = 0.5;

	var landTime:Float;	
	var hasLanded:Bool;
	
	static var DebrisImageCache:IntMap<Tile>; 

	/**
	 * Image is a small 2x2 sprite of the given color.
	 * @param	lifeTime
	 * @param	vx
	 * @param	vy 
	 * @param	color
	 */
	public function new(lifeTime:Float, vx:Float, vy:Float, color:Int) {
		super(lifeTime, vx, vy);
		size = { width:2, height:2 };
		setImage(getDebrisImageForColor(color));
		setCollisionBox(14, 14, 2, 2);
		landTime = LAND_TIME * lifeTime;
		hasLanded = false;
	}
	
	function getDebrisImageForColor(color:Int):Tile {
		if (DebrisImageCache == null) {
			DebrisImageCache = new IntMap<Tile>();
		}
		if (DebrisImageCache.exists(color)) {
			return DebrisImageCache.get(color);
		}
		var t = Tile.fromColor(color, 2, 2);
		DebrisImageCache.set(color, t);
		return t;
	}
	
	/**
	 * Debris are not destroyed but land when colliding with world.
	 * @param	colFlags
	 * @param	vx
	 * @param	vy
	 */
	override function onWorldCollision(colFlags:EnumFlags<ColFlags>, vx:Float, vy:Float) {
		hasLanded = true;
	}
	
	override function updateMotion(elapsed:Float) {
		// land?
		if (!hasLanded) {
			hasLanded = time >= landTime;
		}
		if (hasLanded) {
			vx = vy = 0;
		}
	}
	
	/**
	 * Spin while moving, fade out when landed.
	 * @param	elapsed
	 */
	override function updateEffect(elapsed:Float) {
		if (hasLanded) {
			// fade out
			var t = time / lifeTime;
			bitmap.alpha = 1.0 - (t * t);			
		} else {
			// spin
			var spin = Math.sqrt(vx * vx + vy + vy);
			rotation += SPIN_FACTOR * spin * 2 * Math.PI * elapsed;
		}
		
	}
	
}