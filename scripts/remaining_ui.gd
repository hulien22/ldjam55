class_name remaining_ui
extends Control

var count = 100
var gold = 0
@export var count_text: Label
@export var count_gold: Label
@export var timer: Timer

func _ready():
	count_text.text = str(count)
	timer.connect("timeout", self._on_timer_timeout)

func _process(delta):
	count_gold.text = str(gold)

func on_death(x, y):
	count -= 1
	count_text.text = str(count)

	#the player caused the death of this NPC
	if x.player:
		gold += 25
		

func _on_timer_timeout():
	gold+=1
