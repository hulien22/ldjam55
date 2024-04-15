class_name storm_class
extends Node2D

var stormTimer: Timer
var stormShrinkTimer: Timer
var radius
var target
var storm_attacker

@onready var item_spawns = $"../ItemSpawns"
@onready var fog = $"../fog"

# Called when the node enters the scene tree for the first time.
func _ready():
	storm_attacker = npc_base_stats.new()
	storm_attacker.first_name = "The storm"
	radius = 5000
	fog.material.set_shader_parameter("radius", radius)
	stormTimer = $StormTimer
	stormTimer.connect("timeout", self._on_storm_timer)
	stormShrinkTimer = $StormShrinkTimer
	stormShrinkTimer.connect("timeout", self._on_storm_shrink_timer)
	stormTimer.start()


func _on_storm_timer():
	if radius < 1000:
		stormTimer.stop()
	if radius < 2000 and radius > 1501:
		item_spawns.on_spawn_final()
	if radius < 4000 and radius > 3501:
		item_spawns.on_spawn_mid()
	target = radius-500
	stormShrinkTimer.start()
	

func _on_storm_shrink_timer():
	radius -= 8
	if radius < target:
		stormShrinkTimer.stop()
	fog.material.set_shader_parameter("radius", radius)
