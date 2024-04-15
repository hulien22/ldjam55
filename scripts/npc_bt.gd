extends Node2D
class_name NPCBT

@onready var nav_agent_component = $NavAgentComponent
@onready var sprite_holder = $SpriteHolder
@onready var attack_animation_player = %AttackAnimationPlayer
@onready var weapon_sprite = %WeaponSprite
@onready var character_inside = %CharacterInside
@onready var left_hand = %LeftHand
@onready var right_hand = %RightHand
@onready var name_label = $name_label
@onready var arrow_spawn_marker = $SpriteHolder/ArrowSpawnMarker
@onready var npc_ai = $NpcAi as BeehaveTree


#TODO remove
@export var size: int = 500

# Needs to be > NavAgent's Target desired distance ^ 2
@export var attack_range_sq: int = 4000

@export var arrow_scene:PackedScene

var _action_planner: GoapActionPlanner = GoapActionPlanner.new()
var enemies_in_range: Array[NPCBT] = []
var _blackboard: Dictionary = {}
var _can_attack: bool = true
var _can_dash: bool = true
var _taking_damage: bool = false
var _is_fleeing: bool = false
var _firing_ranged: bool = false
var _in_attack_anim: bool = false

var _locked_animation_count: int = 0

# TODO move elsewhere (component)
var _health: float = 10
var _cooldown: float = 0.5

var base_stats: npc_base_stats
var my_line

#TODO move elsewhere
enum WEAPON_TYPE {
	PUNCH, DAGGER, SWORD, HAMMER, BOW
}
var weapon: WEAPON_TYPE = WEAPON_TYPE.PUNCH

signal died

func test(a):
	return a

func _ready():
	$name_label.text = base_stats.first_name + " '" + str(base_stats.number) + "' " + base_stats.last_name
	my_line = Line2D.new()
	my_line.default_color = Color.RED
	add_child(my_line)

	_health = base_stats.max_health
	_cooldown = randf() * 0.5 + 1.1
	
	weapon = WEAPON_TYPE.values()[ randi() % WEAPON_TYPE.size() ]
	#weapon = WEAPON_TYPE.BOW
	match weapon:
		WEAPON_TYPE.PUNCH:
			weapon_sprite.hide()
		WEAPON_TYPE.DAGGER:
			weapon_sprite.show()
			weapon_sprite.frame = 0
		WEAPON_TYPE.SWORD:
			weapon_sprite.show()
			weapon_sprite.frame = 11
		WEAPON_TYPE.HAMMER:
			weapon_sprite.show()
			weapon_sprite.frame = 10
			_cooldown += 1.0
		WEAPON_TYPE.BOW:
			weapon_sprite.show()
			weapon_sprite.frame = 9
			_cooldown += 2.0
			attack_range_sq = 250000 #500^2
	
	character_inside.set_self_modulate(base_stats.color)
	left_hand.set_self_modulate(base_stats.color)
	right_hand.set_self_modulate(base_stats.color)
	name_label.set_self_modulate(base_stats.color)

func get_action_planner() -> GoapActionPlanner:
	return _action_planner

func get_blackboard() -> Dictionary:
	return _blackboard

#func _physics_process(delta):
	#calculate_state()
	##TODO do we want to do stuff with calling npc_ai.tick()?
	#npc_ai.tick()

# Calculate at the start of finding a goal
func calculate_state():
	var closest_enemy: NPCBT = get_nearest_enemy()
	var visible_enemies = get_visible_enemies()
	#var closest_enemy_dist:float = closest_enemy.global_position.distance_squared_to(global_position)
	
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
		"is_fleeing": _is_fleeing
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
	if (area == $HitBox):
		return
	if (area != null&&area.get_parent() is NPCBT):
		enemies_in_range.push_back(area.get_parent())

func _on_scan_region_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int):
	if (area == $HitBox):
		return
	if (area != null&&area.get_parent() is NPCBT):
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
		else:
			my_line.clear_points()
			my_line.add_point(Vector2.ZERO)
			my_line.add_point(enemy.global_position-global_position)
	if len(enemies_in_range) != len(visible):
		print("of " + str(len(enemies_in_range)) + " enemies " + str(len(visible)) + " are visible.")
	else:
		my_line.clear_points()
	return visible
		

func attack_enemy(enemy):
	#modulate = Color.RED
	#print(self, " -> ", enemy)
	#enemy.damage(1, base_stats, global_position)
	if enemy == null:
		return
	
	_can_attack = false
	var knockback:float = 100
	var time_mult = 1.0
	match weapon:
		WEAPON_TYPE.PUNCH:
			attack_animation_player.play("punch")
			knockback = 100
		WEAPON_TYPE.DAGGER:
			attack_animation_player.play("punch")
			knockback = 100
		WEAPON_TYPE.SWORD:
			attack_animation_player.play("swing")
			knockback = 100
		WEAPON_TYPE.HAMMER:
			time_mult = 1.0
			attack_animation_player.play("swing", -1, time_mult)
			knockback = 200
		WEAPON_TYPE.BOW:
			time_mult = 1.0
			attack_animation_player.play("shoot", -1, time_mult)
			knockback = 0
	
	if (weapon == WEAPON_TYPE.BOW):
		# Animations fires after 0.7 seconds
		#var target: Vector2 = enemy.global_position + Vector2(randf() * -10, randf() * -10)
		get_tree().create_timer(0.6 * (1.0 / time_mult)).timeout.connect(func():
			var arrow:Arrow = arrow_scene.instantiate()
			get_parent().add_child(arrow)
			arrow.global_position = arrow_spawn_marker.global_position
			arrow.init(base_stats, 100, Vector2.RIGHT.rotated(sprite_holder.rotation), 10, 1.0)
		)
		# slow down movement while firing
		cancel_movement()
		_firing_ranged = true
	else:
		# Animations strike after 0.5 seconds
		get_tree().create_timer(0.4 * (1.0 / time_mult)).timeout.connect(func():
			for e in enemies_in_range:
				if e.global_position.distance_squared_to(global_position) <= attack_range_sq * 1.1:
					var angle = global_position.angle_to_point(e.global_position)
					if angle_difference(angle, sprite_holder.rotation) < 0.785398: #45 degrees diff so 90 degrees total
						print(self, " -> ", e)
						e.damage(1, base_stats, global_position, knockback)
		)
	get_tree().create_timer(_cooldown).timeout.connect(func():
		_can_attack=true
	)
	_in_attack_anim = true
	get_tree().create_timer(1).timeout.connect(func():
		_in_attack_anim = false
		_firing_ranged = false
	)

func damage(dmg: float, attacker: npc_base_stats, damage_posn: Vector2, knockback: float):
	if (dmg > 0 && _taking_damage):
		return
	_health -= dmg
	$ProgressBar.value = _health * 100.0 / float(base_stats.max_health)
	if (_health <= 0):
		died.emit(attacker, base_stats)
		print(base_stats.first_name + " " + base_stats.last_name + " has died :(")
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


func rest():
	damage(-0.01, base_stats, global_position, 0)

func explore():
	move_towards(Vector2(randi() %size - size / 2, randi() %size - size / 2))
	#modulate = Color.BLUE

func move_towards(posn: Vector2, is_fleeing:bool = false):
	nav_agent_component.update_target_position(posn)
	_is_fleeing = is_fleeing
	#modulate = Color.GREEN

func get_speed_mod() -> float:
	var speed_mod: float = 1.0
	if _firing_ranged:
		speed_mod *= 0.2
	if _is_fleeing:
		#TODO check if too high?
		speed_mod *= 1.2
	return speed_mod

func cancel_movement():
	nav_agent_component.cancel_movement()
	_is_fleeing = false

func done_movement() -> bool:
	return nav_agent_component.done_movement()

func update_sprites(next_posn: Vector2):
	if _in_attack_anim:
		return 
	var enemy_posn:Vector2 = _blackboard.get("closest_enemy_posn", Vector2.ZERO)
	if _is_fleeing || enemy_posn == Vector2.ZERO:
		sprite_holder.look_at(next_posn)
		return
	sprite_holder.look_at(enemy_posn)

func get_priority(goal:String):
	match goal:
		"FightEnemy":
			return 8
		"Explore":
			return 2
		"Survive":
			var mh:float = base_stats.max_health
			var ch:float = _health
			if (mh <= 0 || ch <= 0):
				return 0
			# TODO different formula
			return (1.0 - ch / mh) * 10
	return 0
