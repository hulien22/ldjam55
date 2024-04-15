@tool
class_name BBoardCompareBBoardCondition extends ConditionLeaf

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

@export var property1: String = ""
## Comparison operator.
@export_enum("==", "!=", ">", "<", ">=", "<=") var operator: int = 0
@export var property2: String = ""


func tick(actor: Node, blackboard: Blackboard) -> int:
	var left: Variant = blackboard.get_value(property1)
	if (left == null):
		return FAILURE
		
	var right: Variant = blackboard.get_value(property2)
	if (right == null):
		return FAILURE

	var result: bool = false
	
	match operator:
		Operators.EQUAL:            result = left == right
		Operators.NOT_EQUAL:        result = left != right
		Operators.GREATER:          result = left > right
		Operators.LESS:             result = left < right
		Operators.GREATER_EQUAL:    result = left >= right
		Operators.LESS_EQUAL:       result = left <= right

	#print(actor.base_stats.number, " | check bool ", property, " res: ", result)
	
	return SUCCESS if result else FAILURE

