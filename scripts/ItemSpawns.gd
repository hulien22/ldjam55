extends Node2D

@onready var item_holder = $"../ItemHolder"

func _ready():
	for child in $corn.get_children():
		item_holder.add_item_from_map(child.global_position, ItemRegistry.getRandomItem())
	for child in $outskirts.get_children():
		item_holder.add_item_from_map(child.global_position, ItemRegistry.getRandomItem())

func on_spawn_mid():
	for child in $mid.get_children():
		item_holder.add_item_from_map(child.global_position, ItemRegistry.getRandomItem())
		
func on_spawn_final():
	for child in $supercorn.get_children():
		item_holder.add_item_from_map(child.global_position, ItemRegistry.getRandomItem())
