extends Node2D

@export var npc_scene: PackedScene
@export var spawn_radius: float = 3100
@export var kill_feed_scene: kill_feed
@export var remaining_ui_scene: remaining_ui
@export var camera_controller: MoveCamera
# Called when the node enters the scene tree for the first time.
func _ready():
	print(len(NpcRegistry.contestants))
	if len(NpcRegistry.contestants) == 0: # didnt use main menu for testing
		NpcRegistry.generate_initial_npcs(100)
		NpcRegistry.set_chosen_candidate(0)
	var angle_offset = 2*PI / float(len(NpcRegistry.contestants))
	for npc in NpcRegistry.contestants:
		var npc_instance = npc_scene.instantiate()
		npc_instance.set_name("contestant" + str(npc.number))
		npc_instance.base_stats = npc
		npc_instance.global_position = Vector2.from_angle(angle_offset*npc.number)*spawn_radius
		if kill_feed_scene:
			npc_instance.connect("died", kill_feed_scene.on_contestant_killed)
		if remaining_ui_scene:
			npc_instance.connect("died", remaining_ui_scene.on_death)
		add_child(npc_instance)
		if npc.number == NpcRegistry.chosen:
			camera_controller.target = npc_instance
	
