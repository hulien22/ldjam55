extends Control

@onready var navigation_region_2d = $"../../NavigationRegion2D"
@onready var item_holder = $"../../ItemHolder"
var map_rid

# Called when the node enters the scene tree for the first time.
func _ready():
	map_rid = navigation_region_2d.get_navigation_map()

func _can_drop_data(at_position, data):
	return typeof(data) == TYPE_DICTIONARY and data.has("summon_stats")
	
func _drop_data(at_position, data):
	item_holder.add_item(map_rid, data["summon_stats"])
	#remove from summon bar
	var origin_node = data["origin_node"]
	if origin_node is SlotTexture:
		origin_node.remove_summon(origin_node)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
