extends Area2D
class_name Arrow

var _base_stats: npc_base_stats
var _dmg: float
var _velocity:Vector2
var _lifetime:float

@onready var arrow_hitbox = $ArrowHitbox

func init(stats: npc_base_stats, speed: float, dir: Vector2, lifetime: float, dmg: float):
	_base_stats = stats
	_lifetime = lifetime
	_dmg = dmg
	_velocity = dir.normalized() * speed
	rotate(_velocity.angle())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	_lifetime -= delta
	if (_lifetime <= 0):
		# TODO animation
		queue_free()
		return
	position += _velocity * delta

func _on_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int):
	if (area == arrow_hitbox):
		return

	if (area == null):
		pass
	elif (area.get_parent() is NPC || area.get_parent() is NPCBT || area.get_parent() is Wolf):
		area.get_parent().damage(_dmg, _base_stats, global_position, 0)
	elif (area.get_parent() is Arrow):
		if (area.get_parent()._base_stats.number == _base_stats.number):
			return
	queue_free()

# Walls
func _on_body_entered(body):
	queue_free()
