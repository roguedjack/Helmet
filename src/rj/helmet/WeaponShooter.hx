package rj.helmet;

/**
 * ...
 * @author roguedjack
 */
class WeaponShooter {
	
	private static inline var OFFSET = 8.0;
	
	public var owner(default, null):Entity;
	public var projectileClass(default, null):Class<Projectile>;
	public var cooldown(default, default):Float;
	public var power(default, default):Int;
	public var canShoot(get, never):Bool;
	var timer:Float;	

	/**
	 * 
	 * @param	owner
	 * @param	projectileClass constructor signature must accept params <owner:Entity, mx:Float, my:Float>
	 * @param	cooldown
	 * @param	power additional power added to the projectile
	 */
	public function new(owner:Entity, projectileClass:Class<Projectile>, cooldown:Float = 1, power:Int=0) {
		this.owner = owner;
		this.projectileClass = projectileClass;
		this.cooldown = cooldown;
		this.power = power;
		timer = cooldown;
	}
	
	function get_canShoot() {
		return timer <= 0;
	}
	
	public function update(elapsed:Float) {
		if (timer > 0) {
			timer -= elapsed;
		}
	}
	
	public function shoot() {
		timer += cooldown;		
		var direction = { x:Math.sin(owner.rotation), y:-Math.cos(owner.rotation) };
		var proj = Type.createInstance(projectileClass, [owner, direction.x, direction.y]);
		if (power != 0) {
			cast(proj, Projectile).power += power;
		}
		Main.Instance.world.spawnEntity(proj, owner.pos.x + direction.x * OFFSET, owner.pos.y + direction.y * OFFSET);
	}
}