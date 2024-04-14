extends Control

var slotOne
var slotTwo
var slotThree

@export var slotOneIcon: TextureRect
@export var slotTwoIcon: TextureRect
@export var slotThreeIcon: TextureRect

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

	timer.connect("timeout", self._refreshShopTimer)
	timer.start()




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _refreshShopTimer():
	slotOne = ItemRegistry.getRandomItem()
	slotTwo = ItemRegistry.getRandomItem()
	slotThree = ItemRegistry.getRandomItem()
		
	slotOneIcon.texture = slotOne.image
	slotTwoIcon.texture = slotTwo.image
	slotThreeIcon.texture = slotThree.image
