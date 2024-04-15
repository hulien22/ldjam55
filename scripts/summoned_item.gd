class_name summoned_item
extends Area2D

@onready var item_sprite = $SpriteHolder/ItemSprite
@export var stats: SummonResource

#TODO specify if summoned by player

# An item that is placed on the map and that can be interacted with / picked up by npcs

func _ready():
	item_sprite.texture = stats.image
	item_sprite.modulate = stats.get_color()
	

