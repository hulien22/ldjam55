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
@onready var npc_audio = $npc_audio
@onready var scan_circle = $ScanRegion/CollisionShape2D


#TODO remove
@export var size: int = 500

# Needs to be > NavAgent's Target desired distance ^ 2
@export var attack_range_sq: int = 4000

@export var arrow_scene:PackedScene

var _action_planner: GoapActionPlanner = GoapActionPlanner.new()
var enemies_in_range: Array = []
var _blackboard: Dictionary = {}
var _can_attack: bool = true
var _can_dash: bool = true
var _taking_damage: bool = false
var _is_fleeing: bool = false
var _firing_ranged: bool = false
var _in_attack_anim: bool = false

var _health_threshold_leave_storm:float = 0.8
var _health_threshold_seek_hpot:float = 0.6
var _health_threshold_flee:float = 0.3

var _range: float = 1000
var _pickup_range_sq: float = pow(30, 2)

var _safe_distance_sq: float = pow(600, 2)
var _consumables_in_range: Array[SummonedItem] = []

var _weapons_in_range: Array[SummonedItem] = []
var _current_weapon_type: SummonResource.WEAPON_TYPE = SummonResource.WEAPON_TYPE.NONE
var _current_weapon: SummonResource = null:
	set(w):
		_current_weapon = w
		if (w == null || w.weapon_type == SummonResource.WEAPON_TYPE.NONE):
			weapon_sprite.hide()
			_cooldown = 1.0
			_current_weapon_type = SummonResource.WEAPON_TYPE.NONE
			return
		match w.weapon_type:
			SummonResource.WEAPON_TYPE.DAGGER:
				weapon_sprite.show()
				weapon_sprite.frame = 0
			SummonResource.WEAPON_TYPE.SWORD:
				weapon_sprite.show()
				weapon_sprite.frame = 11
			SummonResource.WEAPON_TYPE.HAMMER:
				weapon_sprite.show()
				weapon_sprite.frame = 10
			SummonResource.WEAPON_TYPE.BOW:
				weapon_sprite.show()
				weapon_sprite.frame = 9
		_cooldown = w.cooldown_mod + 0.5 #TODO replace with player cooldown or smth
		attack_range_sq = w.range_mod
		weapon_sprite.modulate = w.get_color()
		_current_weapon_type = w.weapon_type

var _locked_animation_count: int = 0

# TODO move elsewhere (component)
var _health: float = 10
var _cooldown: float = 1.5

var base_stats: npc_base_stats
var my_line
var storm_node: storm_class
var time_since_hurt_noise: float = 100

#TODO move elsewhere
#enum WEAPON_TYPE {
	#PUNCH, DAGGER, SWORD, HAMMER, BOW
#}
#var weapon: WEAPON_TYPE = WEAPON_TYPE.PUNCH

signal died

func test(a):
	return a

func on_start():
	npc_ai.enable()

func _ready():
	$name_label.text = base_stats.first_name + " '" + str(base_stats.number) + "' " + base_stats.last_name
	npc_audio.set_name("audio " + str(base_stats.number))
	npc_audio.pitch_scale = base_stats.voice
	my_line = Line2D.new()
	my_line.default_color = Color.RED
	add_child(my_line)

	_health = base_stats.max_health
	#_cooldown = randf() * 0.5 + 1.1

	_range = scan_circle.shape.radius
	_current_weapon = null


	character_inside.set_self_modulate(base_stats.color)
	left_hand.set_self_modulate(base_stats.color)
	right_hand.set_self_modulate(base_stats.color)
	name_label.set_self_modulate(base_stats.color)

func get_action_planner() -> GoapActionPlanner:
	return _action_planner

func get_blackboard() -> Dictionary:
	return _blackboard

func _physics_process(delta):
	time_since_hurt_noise += delta
	if in_the_storm():
		tick_damage(0.001, storm_node.storm_attacker)
	#calculate_state()
	##TODO do we want to do stuff with calling npc_ai.tick()?
	#npc_ai.tick()

# Calculate at the start of finding a goal
func calculate_state():
	var closest_enemy = get_nearest_enemy()
	var visible_enemies = get_visible_enemies()

	var best_weapon_dict: Dictionary = get_nearest_better_weapon()
	var best_weapon: SummonedItem = best_weapon_dict.get("best_weapon")
	var best_weapon_score: float = best_weapon_dict.get("best_score")
	
	var best_consumable: SummonedItem = get_closest_consumable()
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
		"is_fleeing": _is_fleeing,
		"best_weapon": best_weapon,
		"best_weapon_score": best_weapon_score,
		"storm_radius": storm_node.radius,
		"in_storm": in_the_storm(),
		"distance_from_storm": storm_node.radius - global_position.length(),
		"best_consumable": best_consumable,
		"safe_distance_sq": _safe_distance_sq,
		"health_threshold_flee": _health_threshold_flee,
		"health_threshold_leave_storm": _health_threshold_leave_storm,
		"health_threshold_seek_hpot": _health_threshold_seek_hpot,
		"health_percentage": _health / base_stats.max_health,
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

func in_the_storm(p :Vector2 = global_position) -> bool:
	return p.length() > storm_node.radius

func invalid_target_position(p: Vector2) -> bool:
	return !in_the_storm() && in_the_storm(p)

func _on_scan_region_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int):
	if (area == $HitBox || area == null):
		return
	if (area.get_parent() is NPCBT):
		enemies_in_range.push_back(area.get_parent())
	elif (area.get_parent() is Wolf):
		enemies_in_range.push_back(area.get_parent())
	elif (area is SummonedItem):
		match area.stats.summon_type:
			SummonResource.SUMMON_TYPE.WEAPON:
				_weapons_in_range.push_back(area)
			SummonResource.SUMMON_TYPE.CONSUMABLE:
				_consumables_in_range.push_back(area)

func _on_scan_region_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int):
	if (area == $HitBox || area == null):
		return
	if (area.get_parent() is NPCBT):
		enemies_in_range.erase(area.get_parent())
	elif (area.get_parent() is Wolf):
		enemies_in_range.erase(area.get_parent())
	elif (area is SummonedItem):
		match area.stats.summon_type:
			SummonResource.SUMMON_TYPE.WEAPON:
				_weapons_in_range.erase(area)
			SummonResource.SUMMON_TYPE.CONSUMABLE:
				_consumables_in_range.erase(area)

func get_nearest_enemy():
	var closest = null
	var closest_dist: float = 0
	for e in enemies_in_range:
		if (invalid_target_position(e.global_position)):
			continue
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
		#print("of " + str(len(enemies_in_range)) + " enemies " + str(len(visible)) + " are visible.")
		pass
	else:
		my_line.clear_points()
	return visible

func get_closest_consumable() -> SummonedItem:
	var closest:SummonedItem = null
	var closest_dist: float = 0
	for c in _consumables_in_range:
		if (invalid_target_position(c.global_position)):
			continue
		var dist: float = global_position.distance_squared_to(c.global_position)
		if (closest == null||dist < closest_dist):
			closest = c
			closest_dist = dist
	return closest

func get_nearest_better_weapon() -> Dictionary:
	var item:SummonedItem = null
	var best_score:float = -1
	for i in _weapons_in_range:
		# If in the storm, then can chase after (survive will kick us out early)
		# If not in the storm, then ignore stuff in the storm
		if (invalid_target_position(i.global_position)):
			continue
		var s = get_item_score(i)
		if s > best_score:
			best_score = s
			item = i
	return {"best_weapon": item, "best_score": best_score}

func get_item_score(item: SummonedItem) -> float:
	var cur_rarity:int = 0
	match item.stats.summon_type:
		SummonResource.SUMMON_TYPE.WEAPON:
			cur_rarity = 0 if _current_weapon == null else _current_weapon.level
	if item.stats.level <= cur_rarity:
		return -1

	var dist:float = absf(global_position.distance_to(item.global_position))
	var dist_percent:float = 1.0 - dist/_range
	var rarity_mult:float = 1.0 + 0.2 * item.stats.level
	return dist_percent * 10.0 * rarity_mult

func is_item_better(item: SummonedItem) -> bool:
	var cur_rarity:int = 0
	match item.stats.summon_type:
		SummonResource.SUMMON_TYPE.WEAPON:
			cur_rarity = 0 if _current_weapon == null else _current_weapon.level
	return item.stats.level > cur_rarity


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
	match _current_weapon_type:
		SummonResource.WEAPON_TYPE.NONE:
			attack_animation_player.play("punch")
			knockback = 100
		SummonResource.WEAPON_TYPE.DAGGER:
			attack_animation_player.play("punch")
			knockback = 100
		SummonResource.WEAPON_TYPE.SWORD:
			attack_animation_player.play("swing")
			knockback = 100
		SummonResource.WEAPON_TYPE.HAMMER:
			time_mult = 1.0
			attack_animation_player.play("swing", -1, time_mult)
			knockback = 200
		SummonResource.WEAPON_TYPE.BOW:
			time_mult = 1.0
			attack_animation_player.play("shoot", -1, time_mult)
			knockback = 0

	if (_current_weapon_type == SummonResource.WEAPON_TYPE.BOW):
		# Animations fires after 0.7 seconds
		#var target: Vector2 = enemy.global_position + Vector2(randf() * -10, randf() * -10)
		get_tree().create_timer(0.6 * (1.0 / time_mult)).timeout.connect(func():
			var arrow:Arrow = arrow_scene.instantiate()
			get_parent().add_child(arrow)
			arrow.global_position = arrow_spawn_marker.global_position
			var rand_angle = randf() * 0.5 - 0.25 # roughly 30 degrees
			arrow.init(base_stats, 100, Vector2.RIGHT.rotated(sprite_holder.rotation + rand_angle), 10, 1.0)
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
		_firing_ranged = false
	)

func tick_damage(dmg: float, attacker: npc_base_stats):
	_health -= dmg
	_health = clampf(_health, 0, base_stats.max_health)
	$ProgressBar.value = _health * 100.0 / float(base_stats.max_health)
	if (_health <= 0):
		died.emit(attacker, base_stats)
		print(base_stats.first_name + " " + base_stats.last_name + " has died :(")
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
		died.emit(attacker, base_stats)
		print(base_stats.first_name + " " + base_stats.last_name + " has died :(")
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

func rest():
	damage(-0.01, base_stats, global_position, 0)

func pickup_items() -> bool:
	var picked_up_something: bool = false

	#only pickup if we are not currently attacking
	if _can_attack:
		for w in _weapons_in_range:
			if is_item_better(w) && global_position.distance_squared_to(w.global_position) < _pickup_range_sq:
				if w.pick_up():
					_current_weapon = w.stats.duplicate()
					picked_up_something = true
		
		for c in _consumables_in_range:
			if global_position.distance_squared_to(c.global_position) < _pickup_range_sq:
				if c.pick_up():
					#_health += c.stats.health_mod
					damage(-base_stats.max_health, base_stats, global_position, 0)
					picked_up_something = true
	return picked_up_something

func explore():
	move_towards(Vector2(randi() %size - size / 2, randi() %size - size / 2))
	#modulate = Color.BLUE

func move_towards(posn: Vector2, is_fleeing:bool = false):
	nav_agent_component.update_target_position(posn)
	_is_fleeing = is_fleeing
	#modulate = Color.GREEN

func get_speed_mod() -> float:
	var speed_mod: float = base_stats.speed
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

func look_at_closest_enemy():
	var enemy_posn:Vector2 = _blackboard.get("closest_enemy_posn", Vector2.ZERO)
	if enemy_posn != Vector2.ZERO:
		sprite_holder.look_at(enemy_posn)

func get_priority(goal:String) -> float:
	match goal:
		"FightEnemy":
			return 8.0
		"Explore":
			return 0.0
		"Survive":
			#var mh:float = base_stats.max_health
			#var ch:float = _health
			#if (ch >= mh):
				#return -10.0
			#if (mh <= 0 || ch <= 0):
				#return 0.0
			## TODO different formula
			#return (1.0 - ch / mh) * 10.0
			return 998.0
		"PickupItems":
			# always try to do this
			return 1000.0
		"Attack":
			# always try to do this
			return 999.0
		"GetOutOfStorm":
			# just more important than rest
			return 0.2 
		"GetWeapon":
			return _blackboard.get("best_weapon_score")
		"Rest":
			# just more important than explore
			return 0.1
	return 0.0
