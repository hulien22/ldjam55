@tool
class_name CalculateState extends ActionLeaf

func tick(actor, blackboard):
	#print(actor.base_stats.number, " | calc state")
	actor.calculate_state()
	if actor.skip_processing():
		actor.cancel_movement()
		return FAILURE
	return SUCCESS 
