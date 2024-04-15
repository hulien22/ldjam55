@tool
class_name GoToCenterAction extends ActionLeaf

func tick(actor, blackboard):
	#print(actor.base_stats.number, " | roam")
	var new_posn = actor.global_position - actor.global_position.normalized() * 500
	actor.move_towards(new_posn, true) #is_fleeing
	return RUNNING
