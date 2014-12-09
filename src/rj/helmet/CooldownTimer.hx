package rj.helmet;

/**
 * ...
 * @author roguedjack
 */
class CooldownTimer {
	
	public var period(default, default):Float;
	public var time(default, null):Float;
	public var isTick(default, null):Bool;

	public function new(period:Float) {
		this.period = period;
		time = period;
		isTick = false;
	}
	
	public function update(elapsed:Float):Bool {
		if ((time -= elapsed) <= 0) {
			time += period;
			isTick = true;
		} else {
			isTick = false;
		}
		return isTick;
	}
}