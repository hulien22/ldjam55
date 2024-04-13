extends Node

@export var initial_npc_count: int = 100
@export var first_names: Array[String] = ["Mike"]
@export var last_names: Array[String] = ["Wazowski"]

var contestants: Array = []
var _chosen: int = 0

func generate_initial_npcs(count):
	print("generating npcs")
	for i in range(count):
		contestants.append(create_npc_stats(i+1))

func create_npc_stats(number):
	var npc = npc_base_stats.new()
	npc.first_name = first_names[randi_range(0, len(first_names)-1)]
	npc.last_name = last_names[randi_range(0, len(last_names)-1)]
	npc.number = number
	npc.max_health = randi() % 7 + 3
	npc.max_speed = 3
	return npc

func set_chosen_candidate(number):
	_chosen = number
