class_name Shield extends Area2D

@onready var shield_hit_box = %ShieldHitBox

func _ready():
	visible = false
	shield_hit_box.disabled = true

func enable():
	visible = true
	shield_hit_box.disabled = false
