package rj.helmet.entities;
import h2d.filter.Glow;
import hxd.Res;
import rj.helmet.Entity;

using rj.helmet.Entity.EntityType;

/**
 * ...
 * @author roguedjack
 */
class DoorEntity extends Entity {
	
	public var doorGroup(default, null):String;

	public function new(doorGroup:String, isVertical:Bool) {
		super(EntityType.DOOR);
		setImage(Gfx.entities[1]);					
		this.doorGroup = doorGroup;
		canCollide = true;		
		hardCollision = true;
		if (isVertical) {
			rotation = 0.5 * Math.PI;
			setCollisionBox(11, 0, 10, 32);						
		} else {
			setCollisionBox(0, 11, 32, 10);			
		}
	}
	
	/**
	 * Opens this door and all the other doors in the same group.
	 */
	public function open() {
		playSfx(Res.sfx.open_door_wav);
		doOpen();
		// open all the doors in the same group
		for (otherDoor in world.filterEntities(sameDoorGroupFilter)) {
			cast(otherDoor, DoorEntity).doOpen();
		}
	}
	
	function sameDoorGroupFilter(other:Entity):Bool {
		if (other.type != EntityType.DOOR) {
			return false;
		}
		return cast(other, DoorEntity).doorGroup == this.doorGroup;
	}
	
	function doOpen() {
		// TODO ---maybe add sparkles gfx?
		remove();
	}
}