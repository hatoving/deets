extends InteractableStaticBody3D

var regenItems = false
var boughtSomething = false
var alreadyGreeted = false
var mad = false

var itemRegenDuration = 9.0
var itemRegenTimer = 5.0

@onready var idleTex = preload("res://Sprites/Haykeeper/idle.png")
@onready var happyTex = preload("res://Sprites/Haykeeper/happy_0.png")
@onready var sadTex = preload("res://Sprites/Haykeeper/sad.png")
@onready var madTex = preload("res://Sprites/Haykeeper/mad.png")

var currentItems = {
	0 : {},
	1 : {}
}

var diamondBonusItem = {
	"desc" : "[font_size=27][wave amp=20.0 freq=2.0][color=yellow]Diamond Bonus-er[/color][/wave][font_size=18]\n\nAdds X to the bonus counter!",
	"price" : 5,
	"index" : 0
}

var availableItems = {
	0 : {
		chance = 0.8,
		item = {
			"desc" : "[font_size=27][wave amp=20.0 freq=2.0][color=yellow]Horse Food[/color][/wave][font_size=18]\n\nI hear the horse really likes horse food.",
			"origPrice" : 50,
			"price" : 50,
			"item" : "horseFood",
			"index" : 1
		}
	},
	1 : {
		chance = 0.8,
		item = {
			"desc" : "[font_size=27][wave amp=20.0 freq=2.0][color=yellow]Hammer[/color][/wave][font_size=18]\n\nYou can break almost anything with this!",
			"origPrice" : 100,
			"price" : 100,
			"item" : "hammer",
			"index" : 2
		}
	},
	2 : {
		chance = 0.2,
		item = {
			"desc" : "[font_size=27][wave amp=20.0 freq=2.0][color=yellow]Gun[/color][/wave][font_size=18]\n\nHas one bullet. Press RMB to shoot. Use wisely!",
			"origPrice" : 2000,
			"price" : 2000,
			"item" : "gun",
			"index" : 3
		}
	}
}

func _ready() -> void:
	onInteract.connect(_onInteract)
	currentItems[0].clear()
	currentItems[1].clear()
	
	availableItems[2].item.origPrice = int(Global.currentGameLoop.diamondsNeededToEscape / 4)
	availableItems[2].item.price = availableItems[2].item.origPrice
	
	Global.currentShop = self
	
	_regenItems()
	_on_music_finished()
		
func _regenItems():
	var rand = randi_range(0, 1)
	var diamondCount = Global.currentGameLoop.diamondsCollected
	
	var modifiedDiamondItem = diamondBonusItem.duplicate(true)
	modifiedDiamondItem["price"] = int(Global.currentGameLoop.diamondBonusPrice * SaveData.getGameSetting("items", "price_multiplier"))
	currentItems[rand] = modifiedDiamondItem
	
	var opposite = int(!rand)
	var shuffled_keys = availableItems.keys()
	shuffled_keys.shuffle()
	
	for i in range(100):
		for key in shuffled_keys:
			var base_chance = availableItems[key].chance
			var diamond_bonus = min(0.005 * diamondCount, 0.25)
			
			if key == 1:
				diamond_bonus += 0.3
			elif key == 2:
				if Global.currentGameLoop.valuableHorseItemsDestroyed == 4:
					diamond_bonus += 0.3
				else:
					diamond_bonus -= 0.1
					
			var final_chance = clamp(base_chance + diamond_bonus, 0.0, 1.0)
			
			if randf() < final_chance:
				if availableItems[key].item.index == 0:
					continue
					
				if availableItems[key].item.index == 2:
					if Global.currentGameLoop.valuableHorseItemsDestroyed == 4:
						continue
						
				currentItems[opposite] = availableItems[key].item.duplicate(true)
				return
		
func _onInteract():
	Global.currentPlayer.goNumb = true
	Global.currentPlayer.lerpCameraPosToCustom = true
	Global.currentPlayer.lerpCameraCustomPos = Vector3(global_position.x - 2, Global.currentPlayer.global_position.y + 1, global_position.z - 1)
	Global.currentPlayer.lerpHeadYToCustom = true
	Global.currentPlayer.lookAtLerpHeadY = deg_to_rad(-90)
	Global.currentPlayer.lerpPosToCustom = true
	Global.currentPlayer.lerpPosCustom = Vector3(global_position.x - 2, 0.0, global_position.z)
	
	Global.currentGameLoop.isPlayerInShop = true
	Global.shopUI_Toggle()
	
	if !mad:
		$Sprite.texture = idleTex
		$Sprite.scale.y = 0.3
	
	$Sprite/ThankYou.stop()
	if !regenItems and !alreadyGreeted:
		$Sprite/Greeting.play()
		$Area.audio_played.emit($Area)
		alreadyGreeted  = true
	elif regenItems:
		$Sprite.texture = sadTex
		$Sprite.scale.y = 0.3
		if !$Sprite/OuttaStock.playing:
			$Sprite/OuttaStock.play()
			$Area.audio_played.emit($Area)
	
func _buyItem(which):
	var boughtItem = currentItems[which]
	
	match boughtItem["index"]:
		0:
			boughtSomething = true
			print("Adding " + str((Global.currentGameLoop.diamondBonusPrice / 2)) + " to bonus, price is now " + str(Global.currentGameLoop.diamondBonusPrice * 2))
			Global.currentGameLoop.diamondBonus = (Global.currentGameLoop.diamondBonusPrice / 2)
			Global.currentGameLoop.diamondBonusPrice = int((Global.currentGameLoop.diamondBonusPrice * (2 * SaveData.getGameSetting("items", "price_multiplier"))))
		_:
			if Global.currentGameLoop._giveItem(boughtItem["item"], 1) != -1:
				boughtSomething = true
				availableItems[boughtItem["index"] - 1].item.price += int((availableItems[boughtItem["index"] - 1].item.origPrice * 3) * SaveData.getGameSetting("items", "price_multiplier"))
				print("item " + str(boughtItem["item"]) + " now costs: " + str(availableItems[boughtItem["index"] - 1]))
			else:
				$No.play()
				if !$Sprite/InventoryFull.playing:
					$Sprite/Greeting.stop()
					$Sprite/InventoryFull.play()
				return
	
	$Cash.play()
		
	$Sprite.texture = happyTex
	$Sprite.scale.y = 0.3
	Global.currentGameLoop._loseDiamonds(boughtItem["price"])
	
	itemRegenDuration += randf_range(1, 2)
	itemRegenTimer = itemRegenDuration
	print("Item regen will now take " + str(itemRegenDuration) + " seconds...")
	regenItems = true

	_exitShop()

func _exitShop():
	Global.currentPlayer.goNumb = false
	Global.currentPlayer.lerpCameraPosToCustom = false
	Global.currentPlayer.lerpHeadYToCustom = false
	Global.currentPlayer.lerpPosToCustom = false
	Global.shopUI_Toggle()
	Global.currentGameLoop.isPlayerInShop = false
	
	$Sprite/Greeting.stop()
	
	if !regenItems:
		if !boughtSomething:
			mad = true
			$Sprite.texture = madTex
			$Sprite.scale.y = 0.3
			$Area.audio_played.emit($Area)
			$Sprite/NoItem.play()
	else:
		if boughtSomething:
			$Sprite/NoItem.stop()
			$Sprite/ThankYou.play()
			$Area.audio_played.emit($Area)
			boughtSomething = false

func _process(delta: float) -> void:
	$Sprite.scale.y = lerp($Sprite.scale.y, 0.465, 5.0 * delta)
	if Global.currentGameLoop.pauseCoreGameStuff:
		$BoomBox/Music.stream_paused = true
	else:
		$BoomBox/Music.stream_paused = false
	if Global.pauseGame:
		return
		
	if regenItems:
		itemRegenTimer -= delta
		if itemRegenTimer <= 0.0:
			$Sprite/OuttaStock.stop()
			_regenItems()
			Global.gameUI_RevealEvent("[color=orange]The Haykeeper[/color] has restocked it's store...")
			boughtSomething = false
			regenItems = false
	if Global.currentGameLoop.isPlayerInShop:
		if !regenItems:
			for i in range(currentItems.size()):
				if (currentItems[i])["index"] == 0:
					Global.get_node("ShopUI/Control/Item" + str(i + 1) + "/Label").text = ((currentItems[i])["desc"] as String).replace("X", str(Global.currentGameLoop.diamondBonusPrice / 2))
				else:
					Global.get_node("ShopUI/Control/Item" + str(i + 1) + "/Label").text = (currentItems[i])["desc"]
				Global.get_node("ShopUI/Control/Item" + str(i + 1) + "/Diamonds/DiamondsText").text = "[shake]" + str((currentItems[i])["price"])
					
				if Global.currentGameLoop.diamondsCollected < (currentItems[i])["price"]:
					Global.get_node("ShopUI/Control/Item" + str(i + 1) + "/Info").text = "[center][color=red][font_size=18]Press\n[font_size=36][shake]" + ("1" if i == 0 else "2") + "\n[font_size=18]"
				else:
					Global.get_node("ShopUI/Control/Item" + str(i + 1) + "/Info").text = "[center][color=green][font_size=18]Press\n[font_size=36][shake]" + ("1" if i == 0 else "2") + "\n[font_size=18]"
					
			if Input.is_action_just_pressed("deets_buyItem1Shop"):
				if (Global.currentGameLoop.diamondsCollected >= (currentItems[0])["price"]):
					_buyItem(0)
				else:
					$No.play()
			if Input.is_action_just_pressed("deets_buyItem2Shop"):
				if (Global.currentGameLoop.diamondsCollected >= (currentItems[1])["price"]):
					_buyItem(1)
				else:
					$No.play()
		else:
			Global.get_node("ShopUI/OutOfOrder/Info/Label").text = "[center][font_size=27][shake][color=yellow]I'm currently out of order.[/color][/shake][font_size=18]\n\nCome back in %01d seconds for a restock." % itemRegenTimer
		if Input.is_action_just_pressed("deets_exitShop"):
			_exitShop()
		
	Global.get_node("ShopUI/Control").visible = !regenItems
	Global.get_node("ShopUI/OutOfOrder").visible = regenItems
	
	if overlayMat:
		var currentWidth = overlayMat.get_shader_parameter("outline_width")
		overlayMat.set_shader_parameter("outline_width", lerp(currentWidth, targetOutlineWidth, 0.3))


func _on_music_finished() -> void:
	var rand = randi() % 2
	if rand == 1:
		$BoomBox/Music.stream = load("res://Audio/Music/Canon in HORSE.mp3")
	else:
		$BoomBox/Music.stream = load("res://Audio/Music/portableShop.mp3")
	$BoomBox/Music.play()
