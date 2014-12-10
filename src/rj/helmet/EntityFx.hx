package rj.helmet;

/**
 * A temporary effect on an entity.
 * 
 * @author roguedjack
 */
class EntityFx {

	public var hasEnded(default, null):Bool;
	var entity:Entity;
	var time:Float;
	var duration:Float;

	public function new(duration:Float) {
		this.duration = duration;
	}
	
	public function start(e:Entity) {
		entity = e;
		time = 0;
		hasEnded = false;
	}
	
	public function update(elapsed:Float) {
		if (hasEnded) {
			return;
		}
		time += elapsed;
		apply(time > duration ? 1.0 : time / duration);
		if (time >= duration) {
			hasEnded = true;
			onEnd();
		}
	}
	
	/**
	 * Applies the effect.
	 * Default does nothing.
	 * @param	t [0..1]
	 */
	function apply(t:Float) { }
	
	/**
	 * On time ended.
	 * Default does nothing.
	 */
	function onEnd() { }
}