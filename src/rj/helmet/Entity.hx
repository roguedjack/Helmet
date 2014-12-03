package rj.helmet;
import h2d.col.Bounds;
import h2d.Sprite;

@:enum abstract EntityType(Int) {
	var PLAYER = 0;
	var MONSTER = 1;
	var MONSTER_GENERATOR = 2;
	var EXIT = 3;
	var ITEM = 4;
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
		if (sprite != null) {
			sprite.visible = true;
		}
	}
	
	function onHide() {
		if (sprite != null) {
			sprite.visible = false;
		}
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
		if (sprite != null && Main.Instance.view != null) {
			Main.Instance.view.removeEntitySprite(sprite);
		}
	}
	
	public function spawn(x:Float, y:Float) {		
		pos.x = x;
		pos.y = y;
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