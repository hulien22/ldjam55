@tool
class_name PickupItemsAction extends ActionLeaf

func tick(actor, blackboard):
	if (actor.pickup_items()):
		return SUCCESS
	return FAILURE
