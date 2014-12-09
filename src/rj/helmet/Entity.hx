package rj.helmet;
import h2d.Anim;
import h2d.Bitmap;
import h2d.col.Bounds;
import h2d.filter.Glow;
import h2d.Sprite;
import h2d.Tile;
import haxe.EnumFlags;
import hxd.res.Sound;

@:enum abstract EntityType(Int) {
	var PLAYER = 0;
	var MONSTER = 1;
	var MONSTER_GENERATOR = 2;
	var ITEM = 3;
	var PROJECTILE = 4;
	var DOOR = 5;
	var START = 6;
	var EXIT = 7;	
}

enum ColFlags {
	COL_LEFT;
	COL_RIGHT;
	COL_UP;
	COL_DOWN;
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
	var tmpColliders:Array<Entity>;  // to avoid re-allocation each frame

	public function new(type:EntityType) {
		this.type = type;
		world = Main.Instance.world;
		colBox = new Bounds();
		bounds = new Bounds();
		sprite = new Sprite();		
		anchor = new Sprite(sprite);
		bitmap = new Bitmap(null, anchor);
		tmpColliders = new Array<Entity>();
		//nice but horrible fps drop when more than 20+ entities, even if not on screen 
		//bitmap.filters = [ new Glow(0) ];  // black outline effect		
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
		canCollide = false;
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
	
	
	public function spawn(x:Float, y:Float) {		
		pos = { x:x, y:y };
		if (Main.Instance.view != null) {
			Main.Instance.view.addEntitySprite(this);
		}
	}
	
	/**
	 * Try to move, checking and resolving collisions.
	 * To allow sliding movement on walls or other entities, try moving on horizontal and vertical axis separatly.
	 * @param	vx x movement
	 * @param	vy y movement
	 * @return the actual movement after collisions solved
	 */
	public function move(vx:Float, vy:Float):{vx:Float,vy:Float} {			
		var newx = pos.x + vx;
		var newy = pos.y + vy;
		var newvx = vx;
		var newvy = vy;
		
		// check & resolve collisions.
		if (canCollide) {					
			// check collision with entities.
			if (checkEntitiesCollision(vx, vy)) {
				// blocked, don't move.
				return { vx:0, vy:0 };
			}
		
			// check collision with world.
			var col = world.checkWorldCollision(colBox, newx, newy);
			var colFlags:EnumFlags<ColFlags> = new EnumFlags<ColFlags>();			
			if (vx != 0) {
				var col = world.checkWorldCollision(colBox, newx, pos.y);		
				if (vx < 0) {
					if (col.colDL || col.colUL) {
						// forcing alignement cause entities getting stuck in other entities: newx = (col.tl + 1) * Main.TILE_SIZE - colBox.xMin;
						newx = pos.x;
						newvx = 0;
						colFlags.set(COL_LEFT);
					}
				} else {
					if (col.colDR || col.colUR) {
						// forcing alignement cause entities getting stuck in other entities: newx = col.tr * Main.TILE_SIZE - colBox.xMax;
						newx = pos.x;
						newvx = 0;
						colFlags.set(COL_RIGHT);
					}			
				}
			}
			if (vy != 0) {
				var col = world.checkWorldCollision(colBox, newx, newy);		
				if (vy < 0) {
					if (col.colUL || col.colUR) {
						// forcing alignement cause entities getting stuck in other entities: newy = (col.tu + 1) * Main.TILE_SIZE - colBox.yMin;
						newy = pos.y;
						newvy = 0;
						colFlags.set(COL_UP);
					}
				} else {
					if (col.colDL || col.colDR) {
						// forcing alignement cause entities getting stuck in other entities: newy = col.td * Main.TILE_SIZE - colBox.yMax;
						newy = pos.y;
						newvy = 0;
						colFlags.set(COL_DOWN);
					}			
				}
			}				

			if (colFlags.toInt() != 0) {
				onWorldCollision(colFlags, vx, vy);
			}			
		}  // can collide
		
		// update pos & return movement.
		pos = { x:newx, y:newy };
		return { vx:newvx, vy:newvy };
	}
	
	/**
	 * 
	 * @param	vx attempted x movement
	 * @param	vy attempted y movement
	 * @return true if collided with a blocking entity
	 */
	function checkEntitiesCollision(vx:Float, vy:Float):Bool {
		var newx = pos.x + vx;
		var newy = pos.y + vy;
		var newBounds = Bounds.fromValues(newx + colBox.xMin, newy + colBox.yMin, colBox.width, colBox.height);
		var blockingCollision = false;
		
		tmpColliders.splice(0, tmpColliders.length);
		world.listEntitiesIn(newBounds, tmpColliders);
		for (other in tmpColliders) {
			if (other.canCollide && canCollideWith(other) && other.canCollideWith(this)) {
				onCollisionWith(other, vx, vy, true);
				other.onCollisionWith(this, vx, vy, false);
				if (hardCollision && other.hardCollision) {
					blockingCollision = true;
				}
				// if we were removed as a result of the collision, stop checking for collisions!
				if (!canCollide) {
					break;
				}
			}
		}
		
		return blockingCollision;
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
	
	/**
	 * A collision with another entity happened while trying to move one of the two entities.
	 * @param	other
	 * @param	vx attempted x movement of the active entity
	 * @param	vy attempted y movement of the active entity
	 * @param	active true if this entity provoked the collision, false if the other entity provoked the collision
	 */
	function onCollisionWith(other:Entity, vx:Float, vy:Float, active:Bool) { }
	
	/**
	 * A collision happened with the world.
	 * @param	colFlags
	 * @param	vx attempted x movement
	 * @param	vy attempted y movement
	 */
	function onWorldCollision(colFlags:EnumFlags<ColFlags>, vx:Float, vy:Float) { }

	public function playSfx(sfx:Sound, vol:Float = 0.5) {
		sfx.volume = vol;
		sfx.play();
	}
	
	public function update(elapsed:Float) {}
}