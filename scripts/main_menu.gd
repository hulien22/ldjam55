extends Control

@export var play_scene: PackedScene

func on_play():
	print("pressed")
	NpcRegistry.generate_initial_npcs(100)
	get_tree().change_scene_to_packed(play_scene)
