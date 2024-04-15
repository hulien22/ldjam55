@tool
class_name MoveToItemAction extends ActionLeaf

@export var bboard_field:String

func tick(actor, blackboard):
	#print(actor.base_stats.number, " | move into range")
	var item: Node2D = blackboard.get_value(bboard_field)
	if (item == null):
		return FAILURE
		#if (enemy.global_position.distance_squared_to(actor.global_position) < blackboard.get_value("attack_range_sq", 0)):
			#actor.cancel_movement()
			#return SUCCESS
	actor.move_towards(item.global_position)
	return RUNNING
