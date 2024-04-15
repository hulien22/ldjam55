@tool
class_name RoamAction extends ActionLeaf

func tick(actor, blackboard):
	#print(actor.base_stats.number, " | roam")
	actor.explore()
	return SUCCESS
