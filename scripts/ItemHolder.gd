extends Node2D


@export var summon_anim_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func add_item(map_rid,stats):
	var closest_v:Vector2 = NavigationServer2D.map_get_closest_point(map_rid,get_global_mouse_position())
		
	var new_item = summon_anim_scene.instantiate()
	new_item.stats = stats
	new_item.item_holder = self
	add_child(new_item)
	new_item.global_position = closest_v

func add_item_from_map(position, stats):
	var new_item = summon_anim_scene.instantiate()
	new_item.stats = stats
	new_item.item_holder = self
	add_child(new_item)
	new_item.global_position = position
	
func remove_item(item_node):
	remove_child(item_node)
	item_node.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
