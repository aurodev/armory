package armory.trait.internal;

import iron.Trait;
import iron.object.Object;
import iron.object.Transform;
import iron.system.Input;
import iron.math.RayCaster;

class SpaceArmory extends Trait {

	var gizmo:Object;
	var arrowX:Object;
	var arrowY:Object;
	var arrowZ:Object;
	var selected:Transform = null;

	var moveX = false;
	var moveY = false;
	var moveZ = false;

	static var first = true;

	public function new() {
		super();
		
		notifyOnInit(init);
	}

	function init() {
		// gizmo = iron.Scene.active.getChild('ArrowGizmo');
		// arrowX = iron.Scene.active.getChild('ArrowX');
		// arrowY = iron.Scene.active.getChild('ArrowY');
		// arrowZ = iron.Scene.active.getChild('ArrowZ');

		notifyOnUpdate(update);

		if (first) {
			first = false;
			#if (kha_krom && arm_render)
			renderCapture();
			#end
		}
	}

	function update() {

		var keyboard = Input.getKeyboard();
		if (keyboard.started("esc")) trace('__arm|quit');

		// var mouse = Input.getMouse();
		// if (mouse.started("right")) {
		// 	var transforms:Array<Transform> = [];
		// 	for (o in iron.Scene.active.meshes) transforms.push(o.transform);
		// 	var hit = RayCaster.getClosestBoxIntersect(transforms, mouse.x, mouse.y, iron.Scene.active.camera);
		// 	if (hit != null) {
		// 		var loc = hit.loc;
		// 		// gizmo.transform.loc.set(loc.x, loc.y, loc.z);
		// 		// gizmo.transform.buildMatrix();
		// 		selected = hit;
		// 		trace('__arm|select|' + selected.object.name);
		// 	}
		// }

		// if (selected != null) {
		// 	if (mouse.started()) {

		// 		var transforms = [arrowX.transform, arrowY.transform, arrowZ.transform];

		// 		var hit = RayCaster.getClosestBoxIntersect(transforms, mouse.x, mouse.y, iron.Scene.active.camera);
		// 		if (hit != null) {
		// 			if (hit.object.name == 'ArrowX') moveX = true;
		// 			else if (hit.object.name == 'ArrowY') moveY = true;
		// 			else if (hit.object.name == 'ArrowX') moveZ = true;
		// 		}
		// 	}

		// 	if (moveX || moveY || moveZ) {
		// 		Input.occupied = true;

				
		// 		if (moveX) selected.loc.x += mouse.deltaX / 110.0;
		// 		if (moveY) selected.loc.y += mouse.deltaX / 110.0;
		// 		if (moveZ) selected.loc.z += mouse.deltaX / 110.0;
				
		// 		selected.buildMatrix();

		// 		// gizmo.transform.loc.set(selected.loc.x, selected.loc.y, selected.loc.z);
		// 		// gizmo.transform.buildMatrix();
		// 	}
		// }

		// if (mouse.released()) {
		// 	Input.occupied = false;
		// 	// Move operator creator into separate class..
		// 	// Map directly to bl operators - setx to translate
		// 	if (moveX) trace('__arm|setx|' + selected.object.name + '|' + selected.loc.x);
		// 	moveX = moveY = moveZ = false;
		// }

		#if (js && kha_webgl && !kha_node)
		time += iron.system.Time.delta;
		if (time > 1.0) {
			time = 0;
			reloadOnUpdate();
		}
		#end
	}

#if (js && kha_webgl && !kha_node)
	static var time = 0.0;
	static var lastMtime:Dynamic = null;
	function reloadOnUpdate() {
		// Reload page on kha.js rewrite
		var khaPath = "kha.js";
		var xhr = new js.html.XMLHttpRequest();
		xhr.open('HEAD', khaPath, true); 
		xhr.onreadystatechange = function() {
			if (xhr.readyState == 4 && xhr.status == 200) {
				var mtime = xhr.getResponseHeader('Last-Modified');
				if (lastMtime != null && mtime.toString() != lastMtime) {
					untyped __js__('window.location.reload(true)');
				}
				lastMtime = mtime;
			}
		}
		xhr.send();
	}
#end

#if (kha_krom && arm_render)
	static var frame = 0;	
	function renderCapture() {
		App.notifyOnRender(function(g:kha.graphics4.Graphics) {
			frame++;
			if (frame >= 3) {
				var pd = iron.Scene.active.cameras[0].data.pathdata;
				var tex = pd.renderTargets.get("capture").image;
				if (tex != null) {
					var pixels = tex.getPixels();
					Krom.fileSaveBytes("render.bin", pixels.getData());
					// var bo = new haxe.io.BytesOutput();
					// var rgb = haxe.io.Bytes.alloc(tex.width * tex.height * 3);
					// for (i in 0...tex.width * tex.height) {
					// 	rgb.set(i * 3 + 0, pixels.get(i * 4 + 2));
					// 	rgb.set(i * 3 + 1, pixels.get(i * 4 + 1));
					// 	rgb.set(i * 3 + 2, pixels.get(i * 4 + 0));
					// }
					// var pngwriter = new armory.format.png.Writer(bo);
					// pngwriter.write(armory.format.png.Tools.buildRGB(tex.width, tex.height, rgb));
					// Krom.fileSaveBytes("render.png", bo.getBytes().getData());
				}
				kha.System.requestShutdown();
			}
		});
	}
#end
}
