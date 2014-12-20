package rj.helmet;

import h2d.Bitmap;
import h2d.Sprite;
import h2d.Text;
import h2d.Tile;
import hxd.BitmapData;
import hxd.Res;
import hxd.res.FontBuilder;
import rj.helmet.Actor.ActorState;
import rj.helmet.Item.ItemType;

/**
 * ...
 * @author roguedjack
 */
class Hud extends Sprite {
	
	public static inline var WIDTH = 200;
	private static inline var INV_ITEM_SIZE = 16;
	var bg:Bitmap;
	var title:Text;
	var levelTxt:Text;
	var healthTxt:Text;
	var scoreTxt:Text;
	var cachedEntitiesBmp:BitmapData;
	var inventoryBmp:Bitmap;
	var needRefresh:Bool;

	public function new(?parent:Sprite) {
		super(parent);
		
		setPos(Main.WIDTH - WIDTH, 0);
		
		bg = new Bitmap(Tile.fromColor(0, WIDTH, Main.HEIGHT));
		addChild(bg);		
		
		title = new Text(FontBuilder.getFont("arial", 32));
		title.textColor = 0xFF0000;
		title.dropShadow = { dx:2, dy:2, color:0x0F0000, alpha:1 };		
		title.text = 'H E L M E T';		
		Screen.centerTextIn(title, 0, 0, WIDTH, 50);
		addChild(title);
					
		levelTxt = new Text(FontBuilder.getFont("arial", 18));
		levelTxt.textColor = 0xFFFFFF;
		levelTxt.text = "placeholder";
		levelTxt.textAlign = Align.Center;
		levelTxt.dropShadow = { dx:1, dy:1, color:0x0F0F0F, alpha:1 };		
		levelTxt.setPos(10, 50);
		addChild(levelTxt);				
		
		inventoryBmp = new Bitmap();
		inventoryBmp.setPos(0, 100);
		addChild(inventoryBmp);	
		
		healthTxt = new Text(FontBuilder.getFont("arial", 16));
		healthTxt.textColor = 0xFFFFFF;
		healthTxt.text = "placeholder";
		healthTxt.textAlign = Align.Center;
		healthTxt.dropShadow = { dx:1, dy:1, color:0x0F0F0F, alpha:1 };		
		healthTxt.setPos(10, 150);
		addChild(healthTxt);
		
		scoreTxt = new Text(FontBuilder.getFont("arial", 16));  // FIXME --- duplicate font allocation
		scoreTxt.textColor = 0xFFFFFF;
		scoreTxt.text = "placeholder";
		scoreTxt.textAlign = Align.Center;
		scoreTxt.dropShadow = { dx:1, dy:1, color:0x0F0F0F, alpha:1 };		
		scoreTxt.setPos(110, 150);
		addChild(scoreTxt);		
		
		cachedEntitiesBmp = Res.gfx.entities.toBitmap();
		refresh();
	}
	
	public function refresh() {
		needRefresh  = true;
	}
	
	function doRefresh() {
		var player = Main.Instance.world.player;
		var save = Main.Instance.playerSaveData;
		
		levelTxt.text = 'LEVEL : ${save.level}';
				
		inline function drawInventoryItem(canvas:BitmapData, x:Int, y:Int, itType:ItemType) {
			var itile;
			switch (itType) {
				case ItemType.KEY:
					itile = 56;  // FIXME -- duplicate gfx constant, put that somewhere shared.
				default:
					throw "hud: unhandled item type "+itType;
			}
			var srcX = Main.TILE_SIZE * (itile % Main.TILE_SHEET_ROWS);
			var srcY = Main.TILE_SIZE * Math.floor(itile / Main.TILE_SHEET_ROWS);
			canvas.draw(x, y, cachedEntitiesBmp, srcX, srcY, Main.TILE_SIZE, Main.TILE_SIZE);
		}
		
		var canvas:BitmapData = new BitmapData(WIDTH, 100);
		if (player != null) {
			// redraw inventory			
			var x = 0;
			var y = 0;
			for (i in 0...save.nbKeys) {
				drawInventoryItem(canvas, x, 0, ItemType.KEY);
				if ((x += Main.TILE_SIZE) >= WIDTH - Main.TILE_SIZE) {
					x = 0;
					y += Main.TILE_SIZE;
				}
			}
			// update counters
			healthTxt.text = "HEALTH\n" + player.health;
			scoreTxt.text = "SCORE\n" + save.score;
		} else {
			canvas.clear(0);
		}
		inventoryBmp.tile = Tile.fromBitmap(canvas);
		canvas.dispose();
	}
	
	public function update(elapsed:Float) {		
		if (needRefresh) {
			needRefresh = false;
			doRefresh();
		}
	}
}