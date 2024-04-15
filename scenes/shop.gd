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
