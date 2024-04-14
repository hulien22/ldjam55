class_name remaining_ui
extends Control

var count = 100
@export var count_text: Label

func _ready():
	count_text.text = str(count)

func on_death(x, y):
	count -= 1
	count_text.text = str(count)
