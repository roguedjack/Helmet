package rj.helmet.screens;

import h2d.filter.Glow;
import h2d.Text;
import hxd.Key;
import hxd.res.FontBuilder;
import rj.helmet.Main;
import rj.helmet.Screen;
import rj.helmet.entities.PlayerActor.CharacterClass;

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
		Screen.centerTextIn(title, 0, 0.25 * Main.HEIGHT, Main.WIDTH, 0.5 * Main.HEIGHT);
		addChild(title);
		
		msg = new Text(FontBuilder.getFont("arial", 16));
		msg.text = "Press 1 - Play as WARRIOR\n\nPress 2 - Play as VALKYRIE\n\nPress 3 - Play as ELF\n\nPress 4 - Play as WIZARD";
		msg.textColor = 0xFFFFFF;
		msg.textAlign = Align.Center;
		msg.dropShadow = { dx:1, dy:1, color:0, alpha:1 };
		Screen.centerTextIn(msg, 0, 0.5*Main.HEIGHT, Main.WIDTH, 0.75 * Main.HEIGHT);
		addChild(msg);
	}
	
	override public function update(elapsed:Float) {
		super.update(elapsed);
		
		if (Key.isDown(Key.NUMBER_1) || Key.isDown(Key.NUMPAD_1)) {
			game.startNewGame(CharacterClass.WARRIOR);
		} else if (Key.isDown(Key.NUMBER_2) || Key.isDown(Key.NUMPAD_2)) {
			game.startNewGame(CharacterClass.VALKYRIE);
		} else if (Key.isDown(Key.NUMBER_3) || Key.isDown(Key.NUMPAD_3)) {
			game.startNewGame(CharacterClass.ELF);
		} else if (Key.isDown(Key.NUMBER_4) || Key.isDown(Key.NUMPAD_4)) {
			game.startNewGame(CharacterClass.WIZARD);
		}
	}
}