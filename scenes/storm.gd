extends Node2D

var stormTimer: Timer
var stormShrinkTimer: Timer
var radius
var target

func _draw():
	draw_arc(Vector2.ZERO, radius, 0, TAU, 1000, Color.BLACK, 25)

# Called when the node enters the scene tree for the first time.
func _ready():
	radius = 5000
	stormTimer = $StormTimer
	stormTimer.connect("timeout", self._on_storm_timer)
	stormShrinkTimer = $StormShrinkTimer
	stormShrinkTimer.connect("timeout", self._on_storm_shrink_timer)


func _start_storm():
	stormTimer.start()

func _on_storm_timer():
	if radius < 500:
		stormTimer.stop()
	target = radius-500
	stormShrinkTimer.start()
	

func _on_storm_shrink_timer():
	radius -= 5
	if radius < target:
		stormShrinkTimer.stop()
	queue_redraw()