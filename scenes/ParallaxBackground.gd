extends ParallaxBackground
@onready var parallax_layer = $ParallaxLayer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	parallax_layer.motion_offset.x += 20 * delta
