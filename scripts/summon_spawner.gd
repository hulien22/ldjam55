extends Node2D

@export var summon_item_scene: PackedScene
@export var summon_monster_scene: PackedScene
@export var item_holder: Node2D
@export var storm_scene: storm_class
@export var stats: SummonResource
@export var color: Color = Color.WHITE
@onready var sprite_holder = $SpriteHolder
@onready var smoke = $Smoke

func _ready():
	sprite_holder.modulate = color
	sprite_holder.scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(sprite_holder, "scale", Vector2.ONE, 1).set_trans(Tween.TRANS_SPRING)
	tween.tween_callback(func():
		smoke.emitting = true
	)
	get_tree().create_timer(2).timeout.connect(func():
		summon()
		var shrink_tween = create_tween()
		shrink_tween.tween_property(sprite_holder, "scale", Vector2.ONE * 0.2, 1).set_trans(Tween.TRANS_SPRING)
	)

func summon():
	if stats.summon_type == SummonResource.SUMMON_TYPE.MONSTER:
		summon_monster()
		return
	summon_item()

func summon_item():
	var new_item = summon_item_scene.instantiate()
	new_item.stats = stats
	item_holder.add_child(new_item)
	new_item.global_position = global_position

func summon_monster():
	var new_monster = summon_monster_scene.instantiate()
	new_monster.storm_node = storm_scene
	new_monster.stats = stats
	item_holder.add_child(new_monster)
	new_monster.global_position = global_position

func _on_smoke_finished():
	queue_free()
