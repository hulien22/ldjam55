class_name remaining_ui
extends Control

var count = 100
var gold = 0
var stormActive = false
@export var count_text: Label
@export var count_gold: Label
@export var timer: Timer
@export var storm: Node2D
@export var game_over_scene: game_over_ui

signal signal_storm_start

func _ready():
	count_text.text = str(count)
	timer.connect("timeout", self._on_timer_timeout)
	self.connect("signal_storm_start", storm._start_storm)

func _process(delta):
	count_gold.text = str(gold)

	if count < 50 && stormActive==false:
			stormActive = true
			signal_storm_start.emit()

func on_death(x, y):
	count -= 1
	count_text.text = str(count)

	#the player caused the death of this NPC
	if x.player:
		gold += 25
		if count == 1: #player won
			game_over_scene.on_champion_won()
		

func _on_timer_timeout():
	gold+=1
