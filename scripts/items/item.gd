class_name Item
extends Resource

enum WEIGHT_CLASS {LIGHT, MEDIUM, HEAVY}
enum FIGHTER_STATS { HEALTH, DAMAGE, DEFENSE, ATTACK_PER_MINUTE, MOVEMENT_SPEED, RANGE}

@export var level: int
@export var image: Texture2D
