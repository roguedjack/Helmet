package rj.helmet.fx;

import rj.helmet.EntityFx;

/**
 * ...
 * @author roguedjack
 */
class HoverEntityFx extends EntityFx {
	
	var looping:Bool;
	var amplitude:Float;
	var frequency:Float;

	public function new(looping:Bool=true, duration:Float=1, amplitude:Float=4, frequency:Float=1) {
		super(duration);		
		this.looping = looping;
		this.amplitude = amplitude;		
		this.frequency = frequency;
	}
	
	override function apply(elapsed:Float, t:Float) {
		entity.move(0, amplitude * elapsed * Math.sin(frequency * 2 * Math.PI * t));
	}
	
	override function onEnd() {
		if (looping) {
			start(entity);
		}
	}
}