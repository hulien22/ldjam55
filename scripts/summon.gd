class_name Summon
extends Node2D

@export var stats: SummonResource

# Called when the node enters the scene tree for the first time.
func _ready():
	var summon_texture = SummonTexture.new()
	summon_texture.stats = stats
	add_child(summon_texture)
	summon_texture.position = -0.5*stats.image.get_size()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
