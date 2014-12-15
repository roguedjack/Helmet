package rj.helmet;
import haxe.EnumFlags;
import rj.helmet.Entity.ColFlags;

/**
 * ...
 * @author roguedjack
 */
class MonsterAIState {

	public function new() {	
	}
	
	public function onEnter(m:Monster) { }
	
	public function onLeave(m:Monster) { }
	
	public function onUpdate(m:Monster, elapsed:Float) { }
	
	public function onCollisionWith(m:Monster, other:Entity, vx:Float, vy:Float, active:Bool) { }
	
	public function onWorldCollision(m:Monster, colFlags:EnumFlags<ColFlags>, vx:Float, vy:Float) { }
}