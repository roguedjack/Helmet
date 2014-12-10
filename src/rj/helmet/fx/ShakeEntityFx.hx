package rj.helmet.fx;

import rj.helmet.EntityFx;

/**
 * Shake the entity by making small circular moves.
 * 
 * @author roguedjack
 */
class ShakeEntityFx extends EntityFx {
	
	var amplitude:Float;
	var period:Float;

	/**
	 * 
	 * @param	duration
	 * @param	amplitude how far the shaking moves the entity
	 * @param	period how fast the shaking is
	 */
	public function new(duration:Float = 0.25, amplitude:Float = 1, period:Float = 2) {
		super(duration);
		this.amplitude = amplitude;
		this.period = period;
	}
	
	override function apply(t:Float) {
		entity.move(amplitude * Math.sin(period * 2 * Math.PI * t), amplitude * Math.cos(period * 2 * Math.PI * t));
	}
}