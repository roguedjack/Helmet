package rj.helmet.screens;

import h2d.Sprite;
import hxd.Res;
import rj.helmet.Screen;
import rj.helmet.View;

/**
 * ...
 * @author roguedjack
 */
class PlayScreen extends Screen {
	
	public function new(game:Main) {
		super(game);
	}
	
	override public function onEnter() {
		super.onEnter();	
		game.view = new View(this);
	}
	
	override public function onLeave() {
		super.onLeave();
		game.view.remove();
		game.view = null;
	}
	
	override public function update(elapsed:Float) {
		super.update(elapsed);
		if (game.view.messageBox == null) {
			game.world.update(elapsed);
		}
		game.view.update(elapsed);
	}
	
	public function onNewLevel() {
		game.view.onNewLevel();
	}
}