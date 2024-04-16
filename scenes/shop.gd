extends Control

var slotOne
var slotTwo
var slotThree

@export var slotOneIcon: TextureRect
@export var slotTwoIcon: TextureRect
@export var slotThreeIcon: TextureRect

@export var slotOneLabel: Label
@export var slotTwoLabel: Label
@export var slotThreeLabel: Label

@export var remaining: remaining_ui
@export var summon: summon_bar_class

@onready var texture_progress_bar = $ShopPanel/ItemThreePanel/TextureProgressBar
@onready var texture_progress_bar_2 = $ShopPanel/ItemTwoPanel/TextureProgressBar2
@onready var texture_progress_bar_3 = $ShopPanel/ItemOnePanel/TextureProgressBar3


var timer: Timer

var type_filter = [
	SummonResource.SUMMON_TYPE.ARMOR,
	SummonResource.SUMMON_TYPE.CONSUMABLE,
	SummonResource.SUMMON_TYPE.WEAPON,
	SummonResource.SUMMON_TYPE.MONSTER,
	SummonResource.SUMMON_TYPE.SHIELD,
	SummonResource.SUMMON_TYPE.BANNER
]

var level_filter = [1]
var level_thresholds = [60, 35, 20, 5, -10]
var cur_level = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	timer = $Timer
	#populate inital shop
	slotOne = ItemRegistry.getRandomItemFiltered(level_filter, type_filter)
	slotTwo = ItemRegistry.getRandomItemFiltered(level_filter, type_filter)
	slotThree = ItemRegistry.getRandomItemFiltered(level_filter, type_filter)
		
	slotOneIcon.texture = slotOne.image
	slotOneIcon.modulate = slotOne.get_color()
	slotTwoIcon.texture = slotTwo.image
	slotTwoIcon.modulate = slotTwo.get_color()
	slotThreeIcon.texture = slotThree.image
	slotThreeIcon.modulate = slotThree.get_color()
	
	slotOneLabel.text = str(slotOne.cost)
	slotTwoLabel.text = str(slotTwo.cost)
	slotThreeLabel.text = str(slotThree.cost)

	#timer.connect("timeout", self._refreshShopTimer)
	#timer.start()
	start_refresh_pbars()

func _refreshShopTimer():
	if remaining.count <= level_thresholds[cur_level]:
		cur_level += 1
		level_filter.append(cur_level+1)
	slotOne = ItemRegistry.getRandomItemFiltered(level_filter, type_filter)
	slotTwo = ItemRegistry.getRandomItemFiltered(level_filter, type_filter)
	slotThree = ItemRegistry.getRandomItemFiltered(level_filter, type_filter)
		
	slotOneIcon.texture = slotOne.image
	slotOneIcon.modulate = slotOne.get_color()
	slotTwoIcon.texture = slotTwo.image
	slotTwoIcon.modulate = slotTwo.get_color()
	slotThreeIcon.texture = slotThree.image
	slotThreeIcon.modulate = slotThree.get_color()
	slotOneLabel.text = str(slotOne.cost)
	slotTwoLabel.text = str(slotTwo.cost)
	slotThreeLabel.text = str(slotThree.cost)
	start_refresh_pbars()

func start_refresh_pbars():
	var tween = create_tween()
	texture_progress_bar.value = 0
	texture_progress_bar_2.value = 0
	texture_progress_bar_3.value = 0
	tween.set_parallel()
	tween.tween_property(texture_progress_bar, "value", 100, timer.wait_time)
	tween.tween_property(texture_progress_bar_2, "value", 100, timer.wait_time)
	tween.tween_property(texture_progress_bar_3, "value", 100, timer.wait_time)
	tween.set_parallel(false)
	tween.tween_callback(func():
		_refreshShopTimer()
	)

func _on_gui_input(event, extra_arg_0):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		if extra_arg_0 == 1:
			if slotOne:
				if remaining.gold >= slotOne.cost and summon.try_buy_item(slotOne):
					remaining.gold -= slotOne.cost
					slotOneIcon.texture = null
					slotOneLabel.text = "sold"
					slotOne = null
		elif extra_arg_0 == 2:
			if slotTwo:
				if remaining.gold >= slotTwo.cost and summon.try_buy_item(slotTwo):
					remaining.gold -= slotTwo.cost
					slotTwoIcon.texture = null
					slotTwoLabel.text = "sold"
					slotTwo = null
		elif extra_arg_0 == 3:
			if slotThree:
				if remaining.gold >= slotThree.cost and summon.try_buy_item(slotThree):
					remaining.gold -= slotThree.cost
					slotThreeIcon.texture = null
					slotThreeLabel.text = "sold"
					slotThree = null
