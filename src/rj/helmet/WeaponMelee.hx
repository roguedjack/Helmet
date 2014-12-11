package rj.helmet;

/**
 * ...
 * @author roguedjack
 */
class WeaponMelee {
	
	public var owner(default, null):Entity;
	public var cooldown(default, default):Float;
	public var damage(default, default):Int;
	public var canStrike(get, never):Bool;
	var timer:Float;	

	/**
	 * 
	 * @param	owner
	 * @param	cooldown
	 */
	public function new(owner:Entity, damage:Int=1, cooldown:Float = 1) {
		this.owner = owner;
		this.damage = damage;
		this.cooldown = cooldown;
		timer = cooldown;
	}
	
	function get_canStrike() {
		return timer <= 0;
	}
	
	public function update(elapsed:Float) {
		if (timer > 0) {
			timer -= elapsed;
		}
	}
	
	/**
	 * Can damage actors & generators.
	 * @param	target
	 */
	public function strike(target:Entity) {
		timer += cooldown;	
		
		if (Std.is(target, Actor)) {
			cast(target, Actor).takeDamage(owner, damage);
		} else if (Std.is(target, MonsterGenerator)) {
			cast(target, MonsterGenerator).takeHit();
		}
	}	
}