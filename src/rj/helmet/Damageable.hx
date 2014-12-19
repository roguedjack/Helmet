package rj.helmet;

/**
 * Entities that can take damage.
 * 
 * @author roguedjack
 */
interface Damageable {
  
	public function takeDamage(source:Entity, dmg:Int):Void;	
	
}