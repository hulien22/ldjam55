@tool
class_name RestingAction extends ActionLeaf

func tick(actor, blackboard):
	#print(actor.base_stats.number, " | roam")
	
	#TODO more animation stuffs into rest() func..
	actor.rest()
	return SUCCESS
