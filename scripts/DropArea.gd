extends Control

@onready var navigation_region_2d = $"../../NavigationRegion2D"
@onready var item_holder = $"../../ItemHolder"
var map_rid

# Called when the node enters the scene tree for the first time.
func _ready():
	map_rid = navigation_region_2d.get_navigation_map()
	pass # Replace with function body.

func _can_drop_data(at_position, data):
	return typeof(data) == TYPE_DICTIONARY and data.has("summon_stats")
	
func _drop_data(at_position, data):
	var global_v= get_global_mouse_position()
	#add item to world
	#var closest_v:Vector2 = NavigationServer2D.map_get_closest_point(map_rid,get_global_mouse_position())
	item_holder.add_item(global_v,data["summon_stats"])
	print("joe global mouse: ",global_v)
	#print("joe closest V: ",closest_v)
	#item_holder.add_item(at_position,data["summon_stats"])
	#item_holder.add_item(get_global_mouse_position(),data["summon_stats"])
	#remove from summon bar
	var origin_node = data["origin_node"]
	if origin_node is SlotTexture:
		origin_node.remove_summon(origin_node)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
