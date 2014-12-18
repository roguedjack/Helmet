package rj.helmet.fx;

import rj.helmet.EntityFx;

/**
 * ...
 * @author roguedjack
 */
class PushFx extends EntityFx {
	
	public var px(default, default):Float;
	public var py(default, default):Float;	

	/**
	 * 
	 * @param	px
	 * @param	py
	 * @param	duration duration 0 = one-frame instant push
	 */
	public function new(px:Float, py:Float, duration:Float = 0) {
		super(duration);		
		this.px = px;
		this.py = py;
	}
	
	override function apply(elapsed:Float, t:Float) {
		entity.move(px * elapsed, py * elapsed);		
	}
}