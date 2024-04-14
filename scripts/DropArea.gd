extends Control

@onready var navigation_region_2d = $"../../NavigationRegion2D"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _can_drop_data(at_position, data):
	print("joe can drop")
	#may need to update
	#var
	#var closest_v:Vector2 = NavigationServer2D.map_get_closest_point(navigation_region_2d.get_navigation_map(),)
	#return closest_v - 
	#if get_global_mouse_position()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
