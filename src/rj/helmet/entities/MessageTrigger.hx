package rj.helmet.entities;

import rj.helmet.Trigger;

/**
 * Trigger that displays a message box.
 * 
 * @author roguedjack
 */
class MessageTrigger extends Trigger {
	
	public var text(default, null):String;

	public function new(text:String, delay:Float) {
		super(delay, false);		
		this.text = text;
	}
	
	override function fireTrigger() {
		Main.Instance.view.displayMessageBox(text);
	}
}