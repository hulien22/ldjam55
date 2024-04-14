class_name SlotTexture
extends TextureRect

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _can_drop_data(at_position, data):
	return typeof(data) == TYPE_DICTIONARY and data.has("summon_stats") and get_child_count()==0

func _drop_data(at_position, data):
	var summon = SummonTexture.new()
	summon.stats = data["summon_stats"]
	summon.size = summon.stats.image.get_size()*2
	var origin_node = data["origin_node"]
	remove_summon(origin_node)
	add_child(summon)
	
func remove_summon(parent_node):
	for child_node in parent_node.get_children():
		if parent_node is SlotTexture:
			parent_node.remove_child(child_node)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
