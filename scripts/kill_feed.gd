class_name kill_feed
extends Control

@export var kill_feed_item_scene: PackedScene
@export var fade_speed: float
@export var move_speed: float
@export var translation: int

var queued_items: Array[kill_feed_item]
var current_items: Array[kill_feed_item]
var is_moving = false

func temp():
	var x = npc_base_stats.new()
	x.first_name = "Mike"
	x.last_name = "Wazowski"
	x.number = 32
	var y = npc_base_stats.new()
	y.first_name = "Mike"
	y.last_name = "Jbo"
	y.number = 45
	on_contestant_killed(x, y)

func on_contestant_killed(killer: npc_base_stats, killed: npc_base_stats):
	print(str(killer.number) + " has killed " + str(killed.number))
	var item_instance = kill_feed_item_scene.instantiate()
	item_instance.set_data(killer, killed)
	queued_items.push_back(item_instance)
	if len(current_items) == 0:
		add_item()
	elif not is_moving and len(current_items) > 0:
		create_move_tween()

func add_item():
	var item: kill_feed_item = queued_items.pop_front()
	item.modulate.a = 0.0
	#item.position = Vector2(0, 0)
	#item.
	add_child(item)
	current_items.push_back(item)
	create_fade_tween()
	if len(queued_items) > 0:
		create_move_tween()
	else:
		is_moving = false
		
func on_move_finished():
	if len(queued_items) > 0:
		add_item()

func on_fade_finished():
	current_items.pop_front().queue_free()
	
func create_move_tween():
	is_moving = true
	var tween = get_tree().create_tween()
	for item: kill_feed_item in current_items:
		tween.parallel().tween_property(item, "position:y", item.position.y + translation, move_speed)
	tween.tween_callback(on_move_finished)

func create_fade_tween():
	var tween = get_tree().create_tween()
	tween.tween_property(current_items.back(), "modulate:a", 1.0, fade_speed)
	tween.tween_interval(fade_speed)
	tween.tween_property(current_items.back(), "modulate:a", 0.0, fade_speed)
	tween.tween_callback(on_fade_finished)
