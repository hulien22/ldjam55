@tool
class_name AttackTargetAction extends ActionLeaf

func tick(actor, blackboard):
	#print(actor.base_stats.number, " | attack target")
	var enemy: Node2D = blackboard.get_value("closest_enemy")
	if (enemy):
		#actor.cancel_movement()
		actor.attack_enemy(enemy)
		return RUNNING
	return FAILURE
