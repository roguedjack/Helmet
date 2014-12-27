package rj.helmet.entities;

import h2d.filter.ColorMatrix;
import h2d.filter.DropShadow;
import h2d.filter.Glow;
import h3d.Matrix;
import rj.helmet.entities.PlayerActor.CharacterClass;
import rj.helmet.Entity;
import rj.helmet.Entity.EntityType;

/**
 * ...
 * @author roguedjack
 */
class CharacterSelector extends Entity {
	
	public var characterClass:CharacterClass;
	var tint:ColorMatrix;
	var glow:Glow;
	var time:Float;

	public function new(characterClass:CharacterClass, data) {
		super(EntityType.TRAP);
		this.characterClass = characterClass;
		
		var index = cast(characterClass, Int);
		setImage(Gfx.entities[data.gfx[index]]);
		setCollisionBox(data.colbox[0], data.colbox[1], data.colbox[2], data.colbox[3]);
		canCollide = true;		
		hardCollision = true;
		if (data.rotation != 0) {
			rotation = data.rotation * Math.PI / 180.0;
		}
		
		bitmap.filters.push(tint = new ColorMatrix(new Matrix()));
		bitmap.filters.push(glow = new Glow(0xFFFFFF, 1, 1, 4, 4));
	}
	
	override function canCollideWith(other:Entity):Bool {
		if (other.type == EntityType.PLAYER && Main.Instance.playerSaveData.characterClass == characterClass) {
			return false;
		}
		return super.canCollideWith(other);
	}
	
	override function onCollisionWith(other:Entity, vx:Float, vy:Float, active:Bool) {
		if (other.type != EntityType.PLAYER) {
			return;
		}
		if (Main.Instance.playerSaveData.characterClass == characterClass) {
			return;
		}
		
		// select this class
		Main.Instance.selectNewCharacterClass(characterClass);
	}
	
	override public function spawn(x:Float, y:Float) {
		super.spawn(x, y);
		time = 0;
	}
	
	override public function update(elapsed:Float) {
		super.update(elapsed);
		
		if (Main.Instance.playerSaveData.characterClass == characterClass) {
			glow.alpha = 0;
			tint.matrix.identity();
			tint.matrix.colorSaturation(0.1);
			return;
		}
		
		time += elapsed;
		glow.alpha = 0.5 + 0.5 * Math.abs(Math.sin(time * Math.PI));
		tint.matrix.identity();
	}
}