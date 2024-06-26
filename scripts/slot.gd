class_name SlotTexture
extends TextureRect

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _can_drop_data(at_position, data):
	return typeof(data) == TYPE_DICTIONARY and data.has("summon_stats")

func _drop_data(at_position, data):
	var summon = SummonTexture.new()
	summon.stats = data["summon_stats"]
	summon.size = summon.stats.image.get_size()*2
	var origin_node = data["origin_node"]
	
	#clear origin slot or swap summon
	var old_summon = get_summon(self)
	remove_summon(origin_node)
	
	if old_summon!=null && origin_node is SlotTexture:
		var swap_summon = SummonTexture.new()
		swap_summon.stats = old_summon.stats
		swap_summon.size = old_summon.size
		origin_node.add_child(swap_summon)
	
	#clear current slot and add new summon
	remove_summon(self)
	add_child(summon)
	
func remove_summon(parent_node):
	for child_node in parent_node.get_children():
		if parent_node is SlotTexture and child_node is SummonTexture:
			parent_node.remove_child(child_node)
			child_node.queue_free()	

func get_summon(parent_node):
	for child_node in parent_node.get_children():
		if parent_node is SlotTexture and child_node is SummonTexture:
			return child_node
	return null	

func has_item():
	for child_node in get_children():
		if child_node is SummonTexture:
			return true
	return false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
