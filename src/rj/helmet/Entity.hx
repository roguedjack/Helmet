package rj.helmet;
import h2d.Anim;
import h2d.Bitmap;
import h2d.col.Bounds;
import h2d.filter.Glow;
import h2d.Sprite;
import h2d.Tile;

@:enum abstract EntityType(Int) {
	var PLAYER = 0;
	var MONSTER = 1;
	var MONSTER_GENERATOR = 2;
	var ITEM = 3;
	var PROJECTILE = 4;
	var START = 5;
	var EXIT = 6;	
}

/**
 * ...
 * @author roguedjack
 */
class Entity {
	
	public var type(default, null):EntityType;
	public var pos(default, set): { x:Float, y:Float };
	
	/**
	 * Can this entity collide with others? (default False)
	 */
	public var canCollide(default, default):Bool;
	/**
	 * If colliding, is this entity blocking others? (default False)
	 */
	public var hardCollision(default, default):Bool;
	
	public var bounds(default, null):Bounds;

	public var isVisible(get, set):Bool;
	
	public var sprite(default, null):Sprite;
	
	public var rotation(get, set):Float;
		
	var world:World;	
	var colBox:Bounds;
	var bitmap:Bitmap;
	var anchor:Sprite;  // for rotation on center

	public function new(type:EntityType) {
		this.type = type;
		world = Main.Instance.world;
		colBox = new Bounds();
		bounds = new Bounds();
		sprite = new Sprite();		
		anchor = new Sprite(sprite);
		bitmap = new Bitmap(null, anchor);
		bitmap.filters = [ new Glow(0) ];  // black outline effect
	}
	
	function set_pos( p: { x:Float, y:Float } ) {
		pos = p;
		syncCollisionBounds();
		syncSpritePos();
		return pos;
	}

	function get_isVisible() {
		return sprite.visible;
	}
	
	function set_isVisible(b) {
		if (b != sprite.visible) {
			if (b) {
				sprite.visible = true;
				onVisible();
			} else {
				sprite.visible = false;
				onHide();
			}
		}
		return b;
	}
	
	function onVisible() { }
	
	function onHide() { }
	
	function get_rotation() {
		return anchor.rotation;
	}
	
	function set_rotation(r) {		
		anchor.rotation = r;
		return anchor.rotation; 
	}
	
	function syncCollisionBounds() {
		bounds.set(pos.x + colBox.xMin, pos.y + colBox.yMin, colBox.width, colBox.height);
	}
	
	function syncSpritePos() {
		sprite.setPos(pos.x, pos.y);
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
	
	function setImage(t:Tile) {
		anchor.setPos( 0.5 * t.width, 0.5 * t.height);		
		bitmap.setPos( -anchor.x, -anchor.y);
		bitmap.tile = t;
	}
	
	function setCollisionBox(x:Int,y:Int,w:Int, h:Int) {
		colBox = Bounds.fromValues(x, y, w, h);
	}	
	
	
	/**
	 * Check if this entity can collide with another.
	 * Does not test for canCollide flag.
	 * Default return true if the other entity is not this.
	 * @param	other
	 * @return
	 */
	function canCollideWith(other:Entity):Bool {
		return other != this;
	}	
	
	public function spawn(x:Float, y:Float) {		
		pos = { x:x, y:y };
		if (Main.Instance.view != null) {
			Main.Instance.view.addEntitySprite(this);
		}
	}
	
	public function update(elapsed:Float) {}
}