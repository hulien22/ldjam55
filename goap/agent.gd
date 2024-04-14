# Adapted from: https://github.com/viniciusgerevini/godot-goap
#
# This script integrates the actor (NPC) with goap.
# In your implementation you could have this logic
# inside your NPC script.
#
# As good practice, I suggest leaving it isolated like
# this, so it makes re-use easy and it doesn't get tied
# to unrelated implementation details (movement, collisions, etc)
extends Node

class_name GoapAgent

var _goals : Array[GoapGoal]
var _current_goal : GoapGoal
var _current_plan : Array
var _current_plan_step : int = 0

var _last_plan_name: String = ""

var _actor

#
# On every loop this script checks if the current goal is still
# the highest priority. if it's not, it requests the action planner a new plan
# for the new high priority goal.
#
func _process(delta : float):
	_actor.calculate_state()

	# Are we animating or in some other thing and don't want to do any other actions.
	if (_actor.skip_processing()):
		# clear out state since we need to reevaluate goals/plan afterwards (may have disrupted movement for example)
		_current_goal = null
		_last_plan_name = ""
		return
	
	# Are we stuck in some action, in which case don't plan anything new and stick to current plan
	if (_actor.skip_planning()):
		_follow_plan(_current_plan, delta)
		return
	## if any part of our current plan is invalid, try to come up with a new plan and goal
	#if (is_plan_invalid(_current_plan)):
		#_current_goal = null
	
	var goal = _get_best_goal()
	var new_plan:Array = _actor.get_action_planner().get_plan(goal, _actor.get_blackboard())
	#if _current_goal == null or goal != _current_goal:
	if _current_goal == null || !are_plans_equivalent(_current_plan, new_plan):
	# You can set in the blackboard any relevant information you want to use
	# when calculating action costs and status. I'm not sure here is the best
	# place to leave it, but I kept here to keep things simple.
		#var blackboard = {
			#"position": _actor.position,
			#}
#
		#for s in WorldState._state:
			#blackboard[s] = WorldState._state[s]
		_current_goal = goal
		_current_plan = new_plan
		#_current_plan = _actor.get_action_planner().get_plan(_current_goal, _actor.get_blackboard())
		_current_plan_step = 0
		_last_plan_name = ""
	else:
		_follow_plan(_current_plan, delta)


func init(actor, goals: Array[GoapGoal]):
	_actor = actor
	_goals = goals


#
# Returns the highest priority goal available.
#
func _get_best_goal() -> GoapGoal:
	var highest_priority: GoapGoal
	var highest_priority_val: int = 0

	for goal in _goals:
		if goal.is_valid(_actor):
			var priority_val = goal.priority(_actor)
			if (highest_priority == null or priority_val > highest_priority_val):
				highest_priority = goal
				highest_priority_val = priority_val

	return highest_priority


#
# Executes plan. This function is called on every game loop.
# "plan" is the current list of actions, and delta is the time since last loop.
#
# Every action exposes a function called perform, which will return true when
# the job is complete, so the agent can jump to the next action in the list.
#
func _follow_plan(plan: Array, delta: float):
	if plan.size() == 0:
		_last_plan_name = ""
		_current_goal = null
		return

	var current_plan = plan[_current_plan_step] as GoapAction

	var first_time: bool = (_last_plan_name != current_plan.get_clazz())
	if (first_time):
		_last_plan_name = current_plan.get_clazz()

	print(_actor.base_stats.number, " | performing ", current_plan.get_clazz())
	var is_step_complete = current_plan.perform(_actor, delta, first_time)
	
	#print("performing action: ", current_plan.get_clazz() , " | " , is_step_complete)
	if is_step_complete:
		_last_plan_name = ""
		if _current_plan_step < plan.size() - 1:
			_current_plan_step += 1
		else:
			#print("clearing goal: ", _current_goal.get_clazz())
			_current_goal = null

func is_plan_invalid(plan: Array):
	if (plan == null):
		return true
	for action in plan:
		if (action is GoapAction):
			if !action.is_valid(_actor.get_blackboard()):
				return true
		else:
			return true
	return false

func are_plans_equivalent(planA: Array, planB: Array):
	if (planA.size() != planB.size()):
		return false
	for i in planA.size():
		if planA[i].get_clazz() != planB[i].get_clazz():
			return false
	return true
