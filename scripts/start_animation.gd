extends AnimationPlayer

signal start_game
@onready var color_rect = $"../CanvasLayer/start_anim/ColorRect"
@onready var label = $"../CanvasLayer/start_anim/Label"

func _ready():
	label.visible = false
	label.text = "5"
	color_rect.visible = true
	color_rect.material.set_shader_parameter("size", 0.0)
	play("circle_fade_in")

func on_play_low():
	#print("playingh")
	AudioPlayer.play_countdown_low()

func on_play_high():
	AudioPlayer.play_countdown_high()
	start_game.emit()
	
