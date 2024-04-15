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

var timer



# Called when the node enters the scene tree for the first time.
func _ready():
	timer = $Timer
	#populate inital shop
	slotOne = ItemRegistry.getRandomItem()
	slotTwo = ItemRegistry.getRandomItem()
	slotThree = ItemRegistry.getRandomItem()
		
	slotOneIcon.texture = slotOne.image
	slotTwoIcon.texture = slotTwo.image
	slotThreeIcon.texture = slotThree.image
	
	slotOneLabel.text = str(slotOne.cost)
	slotTwoLabel.text = str(slotTwo.cost)
	slotThreeLabel.text = str(slotThree.cost)

	timer.connect("timeout", self._refreshShopTimer)
	timer.start()

func _refreshShopTimer():
	slotOne = ItemRegistry.getRandomItem()
	slotTwo = ItemRegistry.getRandomItem()
	slotThree = ItemRegistry.getRandomItem()
		
	slotOneIcon.texture = slotOne.image
	slotTwoIcon.texture = slotTwo.image
	slotThreeIcon.texture = slotThree.image
	slotOneLabel.text = str(slotOne.cost)
	slotTwoLabel.text = str(slotTwo.cost)
	slotThreeLabel.text = str(slotThree.cost)


func _on_gui_input(event, extra_arg_0):
	if event is InputEventMouseButton and event.is_pressed():
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
