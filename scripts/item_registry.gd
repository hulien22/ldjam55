extends Node

var itemCount: int = 0
@export var items: Array[SummonResource] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	#loadItems("res://resources/items/")
	#print(getItem(0).name)
	pass


func loadItems(path):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir():
				#its a file not a dir
				items.append(load(path + file_name))
				itemCount+=1
				#print(path + file_name)
			file_name = dir.get_next()
			
	else:
		print("An error occurred when trying to access the path.")

func getItem(n):
	return items[n].duplicate()

func getRandomItem():
	return items[randi_range(0, len(items)-1)].duplicate()
	
func getRandomItemFiltered(levels, types):
	var matches = []
	for item in items:
		if item.summon_type in types and item.level in levels:
			matches.append(item)
	return matches[randi_range(0, len(matches)-1)]
