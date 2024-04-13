extends Control

@export var confirm_scene: PackedScene
var candidate_list: ItemList

@export var temp_icon: Texture2D

func _ready():
	candidate_list = $candidate_list
	for candidate in NpcRegistry.contestants:
		candidate_list.add_item(candidate.first_name + " '" + str(candidate.number) + "' " + candidate.last_name, temp_icon)
	NpcRegistry.set_chosen_candidate(0)
	candidate_list.select(0)

func on_confirm():
	get_tree().change_scene_to_packed(confirm_scene)

func on_candidate_selected(position):
	NpcRegistry.set_chosen_candidate(position)
