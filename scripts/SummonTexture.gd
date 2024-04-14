extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready():
	var parentStats = get_parent().stats
	texture = parentStats.image
	pass # Replace with function body.

func _get_drag_data(at_position):
	print(self)
	print()
	var data = {}
	
	var drag_texture = TextureRect.new()
	drag_texture.texture = texture
	drag_texture.rect_position = -0.5 * drag_texture.size
	var control = Control.new()
	control.add_child(drag_texture)
	set_drag_preview(control)
	return data
	
func _process(delta):
	#global_position = get_global_mouse_position()
	pass
	#if Input.is_action_just_released("left_mouse"):
		
		# queue_free()
