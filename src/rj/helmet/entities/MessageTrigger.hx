package rj.helmet.entities;

import hxd.Res;
import rj.helmet.Entity.EntityType;
import rj.helmet.Trigger;

/**
 * Trigger that displays a message box, typically hints.
 * 
 * @author roguedjack
 */
class MessageTrigger extends Trigger {

	public var id(default, null):String;	
	public var text(default, null):String;

	public function new(data) {
		super(data.delay, false);		
		this.id = data.id;
		this.text = data.text;
	}
	
	override function fireTrigger() {
		if (isRemoved) {
			// might happen if another trigger removed us but we fired on the same frame.
			return;
		}
		
		playSfx(Res.sfx.hint_wav);
		Main.Instance.view.displayMessageBox(text);

		// remove all message triggers of same id
		for (otherTrigger in world.filterEntities(sameMessageIdFilter)) {
			otherTrigger.remove();
		}
	}
	
	function sameMessageIdFilter(other:Entity):Bool {
		return other != this && other.type == EntityType.TRIGGER 
			&& Std.is(other, MessageTrigger) && cast(other, MessageTrigger).id == this.id;		
	}
}