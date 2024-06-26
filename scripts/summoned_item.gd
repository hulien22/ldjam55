class_name SummonedItem
extends Area2D

@onready var item_sprite = $SpriteHolder/ItemSprite
@export var stats: SummonResource

# to handle races?
var picked_up: bool = false
#TODO specify if summoned by player

# An item that is placed on the map and that can be interacted with / picked up by npcs

func _ready():
	item_sprite.texture = stats.image
	item_sprite.modulate = stats.get_color()

func pick_up() -> bool:
	if picked_up:
		return false
	picked_up = true
	queue_free()
	return true

