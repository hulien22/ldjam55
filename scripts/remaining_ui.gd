class_name remaining_ui
extends Control

var count = 100
var gold = 10
var stormActive = false
@export var count_text: Label
@export var count_gold: Label
@export var timer: Timer
@export var storm: Node2D
@export var game_over_scene: game_over_ui

var has_player_died = false

signal signal_storm_start

func _ready():
	has_player_died = false
	count_text.text = str(count)
	timer.connect("timeout", self._on_timer_timeout)

func _process(delta):
	count_gold.text = str(gold)

func on_death(x, y):
	count -= 1
	count_text.text = str(count)
	if y.player:
		has_player_died = true
	#the player caused the death of this NPC
	if x.player:
		gold += 10
	if count == 1 and !has_player_died: #player won
		game_over_scene.on_champion_won()
		

func _on_timer_timeout():
	gold+=1
