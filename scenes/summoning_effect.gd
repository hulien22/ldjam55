extends Node2D

@export var summon_scene: PackedScene
@export var item_holder: Node2D
@export var stats: SummonResource
@export var color: Color = Color.WHITE
@onready var sprite_holder = $SpriteHolder
@onready var smoke = $Smoke


# Called when the node enters the scene tree for the first time.
func _ready():
	sprite_holder.modulate = color
	sprite_holder.scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(sprite_holder, "scale", Vector2.ONE, 1).set_trans(Tween.TRANS_SPRING)
	tween.tween_callback(func():
		smoke.emitting = true
	)
	get_tree().create_timer(2).timeout.connect(func():
		summon_item()
	)

func summon_item():
	var new_item = summon_scene.instantiate()
	new_item.stats = stats
	item_holder.add_child(new_item)
	new_item.global_position = global_position
	var tween = create_tween()
	tween.tween_property(sprite_holder, "scale", Vector2.ONE * 0.2, 1).set_trans(Tween.TRANS_SPRING)

func _on_smoke_finished():
	queue_free()
