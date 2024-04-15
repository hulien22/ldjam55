class_name summon_bar_class
extends Control
@onready var slot_1 = $"bar/HBoxContainer/slot 1"
@onready var slot_2 = $"bar/HBoxContainer/slot 2"
@onready var slot_3 = $"bar/HBoxContainer/slot 3"
@onready var slot_4 = $"bar/HBoxContainer/slot 4"
@onready var slot_5 = $"bar/HBoxContainer/slot 5"

var slots
func _ready():
	slots = [slot_1, slot_2, slot_3, slot_4, slot_5]

func try_buy_item(item: SummonResource):
	for slot in slots:
		if not slot.has_item():
			var summon_texture = SummonTexture.new()
			summon_texture.stats = item
			slot.add_child(summon_texture)
			summon_texture.scale = Vector2(2,2)
			#summon_texture.position = -0.5*item.image.get_size()
			return true
	return false
