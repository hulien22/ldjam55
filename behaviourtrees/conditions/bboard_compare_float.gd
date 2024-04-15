@tool
class_name BBoardCompareFloatCondition extends ConditionLeaf

## Compares two values using the specified comparison operator.
## Returns [code]FAILURE[/code] if any of the expression fails or the
## comparison operation returns [code]false[/code], otherwise it returns [code]SUCCESS[/code].

enum Operators {
	EQUAL,
	NOT_EQUAL,
	GREATER,
	LESS,
	GREATER_EQUAL,
	LESS_EQUAL,
}

@export var property: String = ""
@export var default: float = 0
## Comparison operator.
@export_enum("==", "!=", ">", "<", ">=", "<=") var operator: int = 0
@export var target: float = 0


func tick(actor: Node, blackboard: Blackboard) -> int:
	var left: Variant = blackboard.get_value(property, default)
	var result: bool = false
	
	match operator:
		Operators.EQUAL:            result = left == target
		Operators.NOT_EQUAL:        result = left != target
		Operators.GREATER:          result = left > target
		Operators.LESS:             result = left < target
		Operators.GREATER_EQUAL:    result = left >= target
		Operators.LESS_EQUAL:       result = left <= target

	#print(actor.base_stats.number, " | check bool ", property, " res: ", result)
	
	return SUCCESS if result else FAILURE

