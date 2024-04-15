extends Control

@export var confirm_scene: PackedScene
var candidate_list: ItemList

@onready var option_1 = $option1
@onready var option_3 = $option3
@onready var option_2 = $option2

func _ready():
	var rand_1 = randi_range(0, 33)
	var rand_2 = randi_range(34, 66)
	var rand_3 = randi_range(67, 99)
	option_1.set_data(NpcRegistry.contestants[rand_1])
	option_2.set_data(NpcRegistry.contestants[rand_2])
	option_3.set_data(NpcRegistry.contestants[rand_3])
	option_1.connect("candidate_selected", on_candidate_selected)
	option_2.connect("candidate_selected", on_candidate_selected)
	option_3.connect("candidate_selected", on_candidate_selected)
	option_1.on_selected()

func on_confirm():
	get_tree().change_scene_to_packed(confirm_scene)

func on_candidate_selected(position):
	NpcRegistry.set_chosen_candidate(position)
