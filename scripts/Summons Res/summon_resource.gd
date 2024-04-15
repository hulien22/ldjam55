class_name SummonResource
extends Resource

enum SUMMON_TYPE {
	WEAPON,
	ARMOR,
	SHIELD,
	CONSUMABLE,
	MONSTER
}

#level
@export var summon_type: SUMMON_TYPE
@export var level: int
@export var image: Texture2D
@export var name: String
@export var cost: int
#fighting modifiers
@export var health_mod: float
@export var damage_mod: float
@export var defense_mod: float
@export var attack_per_minute_mod: float
@export var range_mod: float

#movement
@export var movement_speed_mod: float
