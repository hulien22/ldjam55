@tool
class_name BBoardCompareNullCondition extends ConditionLeaf

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
## Comparison operator.
@export_enum("==", "!=", ">", "<", ">=", "<=") var operator: int = 1


func tick(actor: Node, blackboard: Blackboard) -> int:
	var left: Variant = blackboard.get_value(property, null)
	var result: bool = false
	
	match operator:
		Operators.EQUAL:            result = left == null
		Operators.NOT_EQUAL:        result = left != null
		Operators.GREATER:          result = left > null
		Operators.LESS:             result = left < null
		Operators.GREATER_EQUAL:    result = left >= null
		Operators.LESS_EQUAL:       result = left <= null
	
	return SUCCESS if result else FAILURE

