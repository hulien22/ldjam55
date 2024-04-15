class_name SummonTexture
extends TextureRect

var stats: SummonResource

# Called when the node enters the scene tree for the first time.
func _ready():
	var collision_shape = CollisionShape2D.new()
	texture = stats.image
	modulate = stats.get_color()

func _get_drag_data(at_position):
	print()
	var data = {}
	data["summon_stats"] = stats
	data["origin_node"] = get_parent()
	
	var drag_texture = TextureRect.new()
	drag_texture.texture = texture
	drag_texture.modulate = stats.get_color()
	drag_texture.size = texture.get_size()
	
	var control = Control.new()
	control.add_child(drag_texture)
	drag_texture.position = (-0.5*drag_texture.size)
	set_drag_preview(control)
	
	return data

func _can_drop_data(at_position, data):
	return false
	
func _process(delta):
	#global_position = get_global_mouse_position()
	pass
	#if Input.is_action_just_released("left_mouse"):
		
		# queue_free()
