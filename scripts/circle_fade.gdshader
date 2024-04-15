shader_type canvas_item;

uniform float size : hint_range(0,1) = 0.5f;

void fragment(){
	if (length((UV-vec2(0.5,0.5))*vec2(1.0, SCREEN_PIXEL_SIZE.x/SCREEN_PIXEL_SIZE.y)) < size){
		discard;
	}
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
