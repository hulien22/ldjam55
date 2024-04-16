class_name SummonResource
extends Resource

enum SUMMON_TYPE {
	WEAPON,
	ARMOR,
	SHIELD,
	CONSUMABLE,
	MONSTER,
	BANNER
}

# this should really be put in a class but im lazy rn
enum WEAPON_TYPE {
	NONE,
	DAGGER,
	SWORD,
	HAMMER,
	BOW
}

#level
@export var summon_type: SUMMON_TYPE
@export var weapon_type: WEAPON_TYPE
@export var level: int
@export var image: Texture2D
@export var name: String
@export var cost: int
#fighting modifiers
@export var health_mod: float
@export var damage_mod: float
@export var defense_mod: float
# keep in mind attack animation takes 1s
@export var cooldown_mod: float
@export var range_mod: float

#movement
@export var movement_speed_mod: float

func get_color() -> Color:
	# don't color consumables
	if summon_type == SUMMON_TYPE.BANNER:
		return Color.LIME_GREEN
	if summon_type == SUMMON_TYPE.CONSUMABLE:
		return Color.WHITE
	match level:
		1:
			return Color.GRAY
		2:
			return Color.LIME_GREEN
		3:
			return Color.CORNFLOWER_BLUE
		4:
			return Color.DARK_ORCHID
		_:
			return Color.GOLD
