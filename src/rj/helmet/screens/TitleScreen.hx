package rj.helmet.screens;

import h2d.filter.Glow;
import h2d.Text;
import hxd.Key;
import hxd.res.FontBuilder;
import rj.helmet.Main;
import rj.helmet.Screen;

/**
 * ...
 * @author roguedjack
 */
class TitleScreen extends Screen {
	
	var title:Text;
	var msg:Text;

	public function new(game:Main) {
		super(game);

		title = new Text(FontBuilder.getFont("arial", 64));
		title.text = 'H E L M E T';
		title.textColor = 0xFF0000;
		title.dropShadow = { dx:2, dy:2, color:0x0F0000, alpha:1 };
		centerTextIn(title, 0, 0.25 * Main.HEIGHT, Main.WIDTH, 0.5 * Main.HEIGHT);
		addChild(title);
		
		msg = new Text(FontBuilder.getFont("arial", 16));
		msg.text = "Press SPACE to play";
		msg.textColor = 0xFFFFFF;
		msg.dropShadow = { dx:1, dy:1, color:0, alpha:1 };
		centerTextIn(msg, 0, 0.5*Main.HEIGHT, Main.WIDTH, 0.75 * Main.HEIGHT);
		addChild(msg);
	}
	
	override public function update(elapsed:Float) {
		super.update(elapsed);

		msg.visible = Std.int(time * 2) % 2 == 0;
		
		if (Key.isDown(Key.SPACE)) {
			game.screen = game.playScreen;
		}
	}
}