package rj.helmet;

import h2d.Sprite;
import h2d.Text;

/**
 * ...
 * @author roguedjack
 */
class Screen extends Sprite {
	
	public var game(default, null):Main;
	var time:Float;

	public function new(game:Main) {
		super();
		this.game = game;
	}
	
	public function onEnter() { 
		time = 0;
		game.s2d.addChild(this);
	}
	
	public function onLeave() {
		game.s2d.removeChild(this);
	}	
	
	public function update(elapsed:Float) { 
		time += elapsed;
	} 
	
	//// Helpers
	
	public static function centerTextIn(t:Text, xMin:Float, yMin:Float, xMax:Float, yMax:Float) {
		t.setPos(xMin + 0.5*(xMax - xMin - t.textWidth), yMin + 0.5*(yMax - yMin - t.textHeight));
	}
}