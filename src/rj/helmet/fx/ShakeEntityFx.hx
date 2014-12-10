package rj.helmet.fx;

import rj.helmet.EntityFx;

/**
 * Shake the entity by making small circular moves.
 * 
 * @author roguedjack
 */
class ShakeEntityFx extends EntityFx {
	
	var amplitude:Float;
	var frequency:Float;

	/**
	 * 
	 * @param	duration
	 * @param	amplitude how far the shaking moves the entity
	 * @param	frequency how fast the shaking is
	 */
	public function new(duration:Float = 0.25, amplitude:Float = 1, frequency:Float = 2) {
		super(duration);
		this.amplitude = amplitude;
		this.frequency = frequency;
	}
	
	override function apply(elapsed:Float, t:Float) {
		entity.move(amplitude * Math.sin(frequency * 2 * Math.PI * t), amplitude * Math.cos(frequency * 2 * Math.PI * t));
	}
}