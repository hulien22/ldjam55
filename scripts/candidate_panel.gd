extends Control

@export var scale_speed: float = 0.1
@export var scale_target: float = 1.2

@onready var char_in = $background/char_out/char_in
@onready var hand_left = $background/char_out/hand_left
@onready var hand_right = $background/char_out/hand_right
@onready var name_label = $background/name
@onready var stats = $background/stats

signal candidate_selected(int)

var number

func set_data(npc_data: npc_base_stats):
	number = npc_data.number
	char_in.modulate = npc_data.color
	hand_left.modulate = npc_data.color
	hand_right.modulate = npc_data.color
	name_label.text = "Candidate " + str(npc_data.number) +"\n" + npc_data.first_name + " " + npc_data.last_name
	stats.text = "Health: " + str(npc_data.max_health) + "\nSpeed: " + str(round(npc_data.speed))
	
func on_selected():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(scale_target, scale_target), scale_speed)
	AudioPlayer.play_pop()
	candidate_selected.emit(number)

func on_deselected(x):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, scale_speed)

func _on_gui_input(event):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		on_selected()
