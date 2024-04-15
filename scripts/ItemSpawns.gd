extends Node2D

@onready var item_holder = $"../ItemHolder"

func _ready():
	for child in $corn.get_children():
		item_holder.add_item_from_map(child.global_position, ItemRegistry.getRandomItemFiltered([1,2], [SummonResource.SUMMON_TYPE.WEAPON, SummonResource.SUMMON_TYPE.CONSUMABLE, SummonResource.SUMMON_TYPE.ARMOR, SummonResource.SUMMON_TYPE.SHIELD]))
	for child in $outskirts.get_children():
		item_holder.add_item_from_map(child.global_position, ItemRegistry.getRandomItemFiltered([1], [SummonResource.SUMMON_TYPE.WEAPON, SummonResource.SUMMON_TYPE.CONSUMABLE, SummonResource.SUMMON_TYPE.ARMOR, SummonResource.SUMMON_TYPE.SHIELD]))

func on_spawn_mid():
	for child in $mid.get_children():
		item_holder.add_item_from_map(child.global_position, ItemRegistry.getRandomItemFiltered([3,4], [SummonResource.SUMMON_TYPE.WEAPON, SummonResource.SUMMON_TYPE.CONSUMABLE, SummonResource.SUMMON_TYPE.ARMOR, SummonResource.SUMMON_TYPE.MONSTER]))
		
func on_spawn_final():
	for child in $supercorn.get_children():
		item_holder.add_item_from_map(child.global_position, ItemRegistry.getRandomItemFiltered([4,5], [SummonResource.SUMMON_TYPE.WEAPON]))
