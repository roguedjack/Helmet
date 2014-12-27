package rj.helmet.entities;
import h2d.filter.Glow;
import hxd.Res;
import rj.helmet.dat.GameData;
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
		var index = (isVertical ? 1 : 0);
		setImage(Gfx.entities[GameData.Door.gfx[index]]);
		this.doorGroup = doorGroup;
		canCollide = true;		
		hardCollision = true;
		if (GameData.Door.rotation[index] != 0) {
			rotation = GameData.Door.rotation[index] * Math.PI / 180.0;
		}
		setCollisionBox(GameData.Door.colbox[index][0],	GameData.Door.colbox[index][1], GameData.Door.colbox[index][2], GameData.Door.colbox[index][3]);		
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
		if (other == this) {
			return false;
		}
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