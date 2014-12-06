package rj.helmet;

/**
 * ...
 * @author roguedjack
 */
class WeaponShooter {
	
	public var owner(default, null):Entity;
	public var projectileClass(default, null):Class<Projectile>;
	public var cooldown(default, default):Float;
	public var canShoot(get, never):Bool;
	var timer:Float;	

	/**
	 * 
	 * @param	owner
	 * @param	projectileClass constructor signature must accept params <owner:Entity, mx:Float, my:Float>
	 * @param	cooldown
	 */
	public function new(owner:Entity, projectileClass:Class<Projectile>, cooldown:Float = 1) {
		this.owner = owner;
		this.projectileClass = projectileClass;
		this.cooldown = cooldown;
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
		Main.Instance.world.spawnEntity(proj, owner.pos.x, owner.pos.y);
	}
}