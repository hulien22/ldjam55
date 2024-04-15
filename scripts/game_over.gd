class_name game_over_ui
extends Control

@export var fade_speed: float

var label: Label
var button: TextureButton
func _ready():
	visible = false
	modulate.a = 0.0
	label = $Label
	button = $Button
	button.disabled = true
	
func on_champion_died(x, y):
	label.text = "Your Chosen One has fallen... Maybe the next one you choose will do better?"
	fade_in()

func on_champion_won():
	label.text = "Your Chosen One is the champion!!"
	fade_in()

func fade_in():
	visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_speed)
	tween.tween_callback(finished_fade)

func finished_fade():
	button.disabled = false

func on_return_to_menu():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
