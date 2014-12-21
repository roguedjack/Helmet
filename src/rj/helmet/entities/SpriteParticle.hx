package rj.helmet.entities;
import h2d.col.Bounds;
import h2d.Tile;

/**
 * ...
 * @author roguedjack
 */
class SpriteParticle extends Particle {

	/**
	 * 
	 * @param	lifeTime
	 * @param	vx
	 * @param	vy
	 * @param	img the image
	 * @param	colbox can be null to disable collision
	 * @param	scaleMin
	 * @param	scaleMax
	 */
	public function new(lifeTime:Float, vx:Float, vy:Float, img:Tile, colbox:Array<Int>, scaleMin:Float = 0.5, scaleMax:Float = 1.0) {
		super(lifeTime, vx, vy);
		setImage(img);
		if (colbox == null) {
			canCollide = false;
		} else {
			setCollisionBox(colbox[0], colbox[1], colbox[2], colbox[3]);
		}
		if (scaleMax >= scaleMin && scaleMin != 1.0) {
			var scale = (scaleMin > scaleMax ? scaleMin + Math.random() * (scaleMax - scaleMin) : scaleMin);			
			bitmap.setScale(scale);
			size = { width:size.width*scale, height:size.height*scale };
		}
	}
	
	/**
	 * Fade out
	 * @param	elapsed
	 */
	override function updateEffect(elapsed:Float) {
		// fade out
		var t = time / lifeTime;
		bitmap.alpha = 1.0 - (t * t);			
	}
}