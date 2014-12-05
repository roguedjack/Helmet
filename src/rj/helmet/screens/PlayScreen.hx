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
				
		game.world.loadLevel(Res.levels.level0);		
		
		game.view.redrawLevelTilesBmp(game.world.mapData);
	}
	
	override public function onLeave() {
		super.onLeave();
		game.view.remove();
		game.view = null;
	}
	
	override public function update(elapsed:Float) {
		super.update(elapsed);
		game.world.update(elapsed);
		game.view.update(elapsed);
	}
}