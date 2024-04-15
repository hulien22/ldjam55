extends Node2D
class_name Wolf

@onready var nav_agent_component = $NavAgentComponent
@onready var sprite_holder = $SpriteHolder
@onready var attack_animation_player = %AttackAnimationPlayer
@onready var sprite = $SpriteHolder/Sprite2D

@onready var npc_ai = $WolfAi as BeehaveTree
@onready var npc_audio = $npc_audio
@onready var scan_circle = $ScanRegion/CollisionShape2D

@export var stats: SummonResource

#TODO remove
@export var size: int = 500

# Needs to be > NavAgent's Target desired distance ^ 2
@export var attack_range_sq: int = 4000


var _action_planner: GoapActionPlanner = GoapActionPlanner.new()
var enemies_in_range: Array[NPCBT] = []
var _blackboard: Dictionary = {}
var _can_attack: bool = true
var _can_dash: bool = true
var _taking_damage: bool = false
var _in_attack_anim: bool = false

var _range: float = 1000
var _locked_animation_count: int = 0

# TODO move elsewhere (component)
var _health: float = 10
var _cooldown: float = 1.5

var base_stats: npc_base_stats
@export var storm_node: storm_class
var time_since_hurt_noise: float = 100


func on_start():
	npc_ai.enable()

func _ready():
	# convert from resource stats to npc stats
	base_stats = npc_base_stats.new()
	base_stats.first_name = stats.name
	base_stats.last_name = ""
	base_stats.number = -1
	base_stats.voice = 1.0
	base_stats.player = false
	
	base_stats.max_health = stats.health_mod
	base_stats.max_speed = stats.movement_speed_mod
	
	sprite.modulate = stats.get_color()
	
	npc_audio.set_name("audio " + str(base_stats.number))
	npc_audio.pitch_scale = base_stats.voice

	_health = base_stats.max_health
	#_cooldown = randf() * 0.5 + 1.1

	_range = scan_circle.shape.radius

func get_action_planner() -> GoapActionPlanner:
	return _action_planner

func get_blackboard() -> Dictionary:
	return _blackboard

func _physics_process(delta):
	time_since_hurt_noise += delta
	
	if global_position.length() > storm_node.radius:
		tick_damage(0.01, storm_node.storm_attacker)
	#calculate_state()
	##TODO do we want to do stuff with calling npc_ai.tick()?
	#npc_ai.tick()

# Calculate at the start of finding a goal
func calculate_state():
	var closest_enemy: NPCBT = get_nearest_enemy()
	var visible_enemies = get_visible_enemies()

	_blackboard = {
		"global_posn": global_position,
		"enemies_in_range": enemies_in_range,
		"closest_enemy": closest_enemy,
		"visible_enemies" : visible_enemies,
		#"distance_sq_to_closest_enemy": closest_enemy_dist,
		#"in_range_of_enemy": (closest_enemy_dist <= attack_range_sq),
		"attack_range_sq": attack_range_sq,
		"can_attack": _can_attack,
		"can_dash": _can_dash,
		"max_health": base_stats.max_health,
		"cur_health": _health,
		"is_moving": nav_agent_component.is_moving(),
		"storm_radius": storm_node.radius
	}
	if closest_enemy != null:
		_blackboard["closest_enemy_posn"] = closest_enemy.global_position

		if (global_position.distance_squared_to(closest_enemy.global_position) < attack_range_sq):
			_blackboard["in_range_of_target"] = true

	npc_ai.blackboard.overwrite_dict(_blackboard)
	#if _can_attack:
		#modulate = Color.GREEN
	#else:
		#modulate = Color.RED

func skip_processing() -> bool:
	return _locked_animation_count > 0

func skip_planning() -> bool:
	return false

func _on_scan_region_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int):
	if (area == $HitBox || area == null):
		return
	# only target NPCs
	if (area.get_parent() is NPCBT):
		enemies_in_range.push_back(area.get_parent())

func _on_scan_region_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int):
	if (area == $HitBox || area == null):
		return
	if (area.get_parent() is NPCBT):
		enemies_in_range.erase(area.get_parent())

func get_nearest_enemy() -> NPCBT:
	var closest: NPCBT = null
	var closest_dist: float = 0
	for e in enemies_in_range:
		var dist: float = global_position.distance_squared_to(e.global_position)
		if (closest == null||dist < closest_dist):
			closest = e
			closest_dist = dist
	return closest

func get_visible_enemies():
	var space_state = get_world_2d().direct_space_state
	var visible = []
	for enemy in enemies_in_range:
		var query = PhysicsRayQueryParameters2D.create(global_position, enemy.global_position)
		var result = space_state.intersect_ray(query)
		if result.is_empty():
			visible.append(enemy)
	return visible

func attack_enemy(enemy):
	#modulate = Color.RED
	#print(self, " -> ", enemy)
	#enemy.damage(1, base_stats, global_position)
	if enemy == null:
		return
	npc_audio.play_attack()
	_can_attack = false
	var knockback:float = 100
	var time_mult = 1.0
	
	attack_animation_player.play("attack")
	# Animations strike after 0.5 seconds
	get_tree().create_timer(0.4 * (1.0 / time_mult)).timeout.connect(func():
		for e in enemies_in_range:
			if e.global_position.distance_squared_to(global_position) <= attack_range_sq * 1.1:
				var angle = global_position.angle_to_point(e.global_position)
				if angle_difference(angle, sprite_holder.rotation) < 0.785398: #45 degrees diff so 90 degrees total
					#print(self, " -> ", e)
					e.damage(1, base_stats, global_position, knockback)
	)
	get_tree().create_timer(_cooldown).timeout.connect(func():
		_can_attack=true
	)
	_in_attack_anim = true
	look_at_closest_enemy()
	get_tree().create_timer(1).timeout.connect(func():
		_in_attack_anim = false
	)

func tick_damage(dmg: float, attacker: npc_base_stats):
	_health -= dmg
	_health = clampf(_health, 0, base_stats.max_health)
	$ProgressBar.value = _health * 100.0 / float(base_stats.max_health)
	if (_health <= 0):
		npc_audio.play_death()
		queue_free()
		return
	if time_since_hurt_noise > 3:
		npc_audio.play_hurt()
		time_since_hurt_noise = 0

func damage(dmg: float, attacker: npc_base_stats, damage_posn: Vector2, knockback: float):
	if (dmg > 0 && _taking_damage):
		return
	_health -= dmg
	_health = clampf(_health, 0, base_stats.max_health)
	$ProgressBar.value = _health * 100.0 / float(base_stats.max_health)
	if (_health <= 0):
		npc_audio.play_death()
		queue_free()
		return
	if (dmg > 0 && !_taking_damage):
		_taking_damage = true;
		_locked_animation_count += 1
		# start animation stuff here
		var new_posn = global_position - (damage_posn - global_position).normalized() * knockback
		var tween = create_tween()
		tween.set_parallel()
		tween.tween_property(self, "global_position", new_posn, 0.5)
		tween.tween_property(sprite_holder, "scale", Vector2.ONE * 2, 0.25)
		tween.tween_property(sprite_holder, "rotation", sprite_holder.rotation + 2*PI, 0.5)
		tween.set_parallel(false)
		tween.tween_property(sprite_holder, "scale", Vector2.ONE, 0.25)
		tween.tween_callback(func():
			_taking_damage = false
			_locked_animation_count -= 1
		)
		npc_audio.play_hurt()
		time_since_hurt_noise = 0

func explore():
	move_towards(Vector2(randi() %size - size / 2, randi() %size - size / 2))
	#modulate = Color.BLUE

func move_towards(posn: Vector2, is_fleeing:bool = false):
	nav_agent_component.update_target_position(posn)
	#modulate = Color.GREEN

func get_speed_mod() -> float:
	var speed_mod: float = 1.0
	return speed_mod

func cancel_movement():
	nav_agent_component.cancel_movement()

func done_movement() -> bool:
	return nav_agent_component.done_movement()

func update_sprites(next_posn: Vector2):
	if _in_attack_anim:
		return
	var enemy_posn:Vector2 = _blackboard.get("closest_enemy_posn", Vector2.ZERO)
	if enemy_posn == Vector2.ZERO:
		sprite_holder.look_at(next_posn)
		return
	sprite_holder.look_at(enemy_posn)

func look_at_closest_enemy():
	var enemy_posn:Vector2 = _blackboard.get("closest_enemy_posn", Vector2.ZERO)
	if enemy_posn != Vector2.ZERO:
		sprite_holder.look_at(enemy_posn)
