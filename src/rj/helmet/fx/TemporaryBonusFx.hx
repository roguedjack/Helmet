package rj.helmet.fx;

import h2d.filter.Glow;
import hxd.Res;
import rj.helmet.entities.BonusItem;
import rj.helmet.entities.PlayerActor;
import rj.helmet.Entity;
import rj.helmet.EntityFx;

/**
 * Applies only to player.
 * 
 * @author roguedjack
 */
class TemporaryBonusFx extends EntityFx {
	
	public var bonusItem(default, null):BonusItem;
	var player:PlayerActor;
	var glow:Glow;

	public function new(b:BonusItem, duration:Float) {
		super(duration);
		this.bonusItem = b;
	}
	
	override public function start(e:Entity) {
		super.start(e);
		if (Std.is(e, PlayerActor)) {
			player = cast e;
			bonusItem.apply(player);
			player.bitmap.filters.push(glow = new Glow(bonusItem.glowColor, 1, 1, 4));
		}
	}
	
	override function onEnd() {
		if (player == null) {
			return;
		}	
		bonusItem.unapply(player);
		player.playSfx(Res.sfx.cancel_bonus_wav);
		player.bitmap.filters.remove(glow);
	}
	
	override function apply(elapsed:Float, t:Float) {
		if (player == null) {
			return;
		}
		// pulse
		var pulse = Math.cos(time * 2 * Math.PI);
		glow.alpha = 0.5 + 0.5 * pulse * pulse;		
	}
}