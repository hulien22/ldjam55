@tool
class_name PrioritySelectorComposite extends SelectorReactiveComposite

func _ready() -> void:
	pass

func custom_sort(a, b) -> bool:
	return a[0] > b[0]

func tick(actor: Node, blackboard: Blackboard) -> int:
	# get ordered children based on priority
	var priority_list: Array = []
	# use name of child as identifier -- actor needs to implement some way to calculate priority from this name
	for c in get_children():
		priority_list.push_back([actor.get_priority(c.name), c])
	priority_list.sort_custom(custom_sort)
	#print(".", actor.base_stats.number, " | ", priority_list)
	
	for p in priority_list:
		var c:Node = p[1]
		# SelectorReactiveComposite's tick below:
		if c != running_child:
			c.before_run(actor, blackboard)

		var response = c.tick(actor, blackboard)
		if can_send_message(blackboard):
			BeehaveDebuggerMessages.process_tick(c.get_instance_id(), response)

		if c is ConditionLeaf:
			blackboard.set_value("last_condition", c, str(actor.get_instance_id()))
			blackboard.set_value("last_condition_status", response, str(actor.get_instance_id()))

		match response:
			SUCCESS:
				# Interrupt any child that was RUNNING before.
				if c != running_child:
					interrupt(actor, blackboard)
				c.after_run(actor, blackboard)
				return SUCCESS
			FAILURE:
				c.after_run(actor, blackboard)
			RUNNING:
				if c != running_child:
					interrupt(actor, blackboard)
					running_child = c
				if c is ActionLeaf:
					blackboard.set_value("running_action", c, str(actor.get_instance_id()))
				return RUNNING

	return FAILURE

func get_class_name() -> Array[StringName]:
	var classes := super()
	classes.push_back(&"PrioritySelectorComposite")
	return classes
