package rj.helmet;
import h2d.Anim;
import h2d.col.Bounds;
import h2d.Sprite;

@:enum abstract EntityType(Int) {
	var PLAYER = 0;
	var MONSTER = 1;
	var MONSTER_GENERATOR = 2;
	var EXIT = 3;
	var ITEM = 4;
	var PROJECTILE = 5;
}

/**
 * ...
 * @author roguedjack
 */
class Entity {
	
	public var type(default, null):EntityType;
	public var pos(default, set): { x:Float, y:Float };
	public var canCollide(default, default):Bool;
	public var bounds(default, null):Bounds;
	public var isVisible(default, set):Bool;
	public var sprite(default, null):Sprite;

	public function new(type:EntityType) {
		this.type = type;
		sprite = new Sprite();
	}
	
	function set_pos( p:{x:Float,y:Float} ) {
		pos = p;
		updateBounds();
		return pos;
	}
	
	function set_isVisible(b) {
		if (b == isVisible) {
			return b;
		}
		b = isVisible;
		if (b) {
			onVisible();
		} else {
			onHide();
		}
		return isVisible;
	}
	
	function onVisible() {
		sprite.visible = true;
	}
	
	function onHide() {
		sprite.visible = false;
	}
	
	function updateBounds() {
		if (bounds == null) {
			return;
		}
		bounds.x = pos.x;
		bounds.y = pos.y;
	}
	
	public function remove() {
		isVisible = false;
		Main.Instance.world.removeEntity(this);
		if (Main.Instance.view != null) {
			Main.Instance.view.removeEntitySprite(this);		
		} else {
			sprite.remove();
		}
	}
	
	public function spawn(x:Float, y:Float) {		
		pos.x = x;
		pos.y = y;
		if (Main.Instance.view != null) {
			Main.Instance.view.addEntitySprite(this);
		}
	}
	
	/**
	 * Check if bounds collide. Does not check for `isColliding` flag.
	 * @param	other
	 * @return
	 */
	public function checkCollisionWith(other:Entity):Bool {
		if (bounds == null || other.bounds == null) {
			return false;
		}
		return bounds.collide(other.bounds);
	}
	
	public function onCollisionWith(other:Entity) {}
	
	public function update(elapsed:Float) {}
}