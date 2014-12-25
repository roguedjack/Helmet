package rj.helmet;

import h2d.Font;
import h2d.HtmlText;
import h2d.Interactive;
import h2d.ScaleGrid;
import h2d.Sprite;
import hxd.Event;
import hxd.res.FontBuilder;

/**
 * ...
 * @author roguedjack
 */
class MessageBox extends Interactive {
	
	public var text(default, set):String;
	var view:View;
	var font:Font;
	var bg:ScaleGrid;
	var html:HtmlText;
	
	function set_text(t:String) {
		this.text = t;
		rebuild();
		return text;
	}

	public function new(view:View, text:String) {
		super(Main.Instance.s2d.width, Main.Instance.s2d.height, view);	
		this.view = view;
		
		font = FontBuilder.getFont("arial", 14);
		bg = new ScaleGrid(Gfx.messageBox, 11, 11, this);
		html = new HtmlText(font, bg);
		html.textColor = 0xFF0000;
		html.setPos(bg.borderWidth, bg.borderHeight);
		this.text = text;
		
		focus();
	}
	
	function rebuild() {			
		html.text = this.text;
		var size = html.getBounds();
		bg.width = Math.round(size.width) + 2 * bg.borderWidth;
		bg.height = Math.round(size.height) + 2 * bg.borderHeight;
		setPos(0.5 * Main.Instance.s2d.width - 0.5 * bg.width, 0.5 * Main.Instance.s2d.height - 0.5 * bg.height);
		
	}
	
	override public function onKeyDown(e:hxd.Event) {
		view.closeMessageBox();
	}
}