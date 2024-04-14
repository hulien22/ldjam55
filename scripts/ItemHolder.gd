extends Node2D

@export var summon_scene: PackedScene
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func add_item(posn,stats):
	var new_item = summon_scene.instantiate()
	new_item.stats = stats
	new_item.global_position = posn
	add_child(new_item)
	
func remove_item(item_node):
	remove_child(item_node)
	item_node.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
