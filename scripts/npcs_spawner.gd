extends Node2D

@export var npc_scene: PackedScene
@export var spawn_radius: float = 10
# Called when the node enters the scene tree for the first time.
func _ready():
	print(len(NpcRegistry.contestants))
	if len(NpcRegistry.contestants) == 0: # didnt use main menu for testing
		print(len(NpcRegistry.contestants))
		NpcRegistry.generate_initial_npcs(100)
		NpcRegistry.set_chosen_candidate(0)
	var angle_offset = 2*PI / float(len(NpcRegistry.contestants))
	print(str(len(NpcRegistry.contestants)) + " " + str(angle_offset))
	for npc in NpcRegistry.contestants:
		var npc_instance = npc_scene.instantiate()
		npc_instance.set_name("contestant" + str(npc.number))
		npc_instance.base_stats = npc
		npc_instance.global_position = Vector2.from_angle(angle_offset*npc.number)*spawn_radius
		print(npc_instance.global_position)
		add_child(npc_instance)
		
