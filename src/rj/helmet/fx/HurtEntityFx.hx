package rj.helmet.fx;
import h2d.filter.Glow;
import rj.helmet.Entity;

/**
 * ...
 * @author roguedjack
 */
class HurtEntityFx extends EntityFx {
	
	public var isActive(default, null):Bool;
	var glow:Glow;

	public function new(duration:Float, color:Int=0xFF0000) {
		super(duration);
		glow = new Glow(color, 1, 1, 4, 4);
	}
	
	public function resetDuration(duration:Float) {
		this.duration = duration;
	}
	
	public function extendDuration(addedTime:Float) {
		duration += addedTime;
	}

	override public function start(e:Entity) {
		super.start(e);
		entity.bitmap.filters.push(glow);
		isActive = true;
	}
		
	override function onEnd() {
		entity.bitmap.filters.remove(glow);
		isActive = false;
	}
}