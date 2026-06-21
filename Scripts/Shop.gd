extends InteractableStaticBody3D

@export var haykeeper: Haykeeper
var regenItems = false
var boughtSomething = false
var alreadyGreeted = false
var mad = false
var itemRegenDuration = 9.0
var itemRegenTimer = 5.0
var currentItems = {
	0: { },
	1: { },
}
var steediumBonusItem = {
	"desc": "[font_size=27][wave amp=20.0 freq=2.0][color=yellow]Steedium Bonus[/color][/wave][font_size=18]\n\nAdds X to the bonus counter!",
	"price": 5,
	"index": 0,
}
var availableItems = {
	0: {
		chance = 0.8,
		item = {
			"desc": "[font_size=27][wave amp=20.0 freq=2.0][color=yellow]Horse Food[/color][/wave][font_size=18]\n\nI hear the horse really likes horse food.",
			"origPrice": 50,
			"price": 50,
			"item": "horseFood",
			"index": 1,
		},
	},
	1: {
		chance = 0.8,
		item = {
			"desc": "[font_size=27][wave amp=20.0 freq=2.0][color=yellow]Hammer[/color][/wave][font_size=18]\n\nYou can break almost anything with this!",
			"origPrice": 100,
			"price": 100,
			"item": "hammer",
			"index": 2,
		},
	},
	2: {
		chance = 0.2,
		item = {
			"desc": "[font_size=27][wave amp=20.0 freq=2.0][color=yellow]Gun[/color][/wave][font_size=18]\n\nHas one bullet. Press RMB to shoot. Use wisely!",
			"origPrice": 2000,
			"price": 2000,
			"item": "gun",
			"index": 3,
		},
	},
}
const SIGN_TEXT = [
	"type\nhorse\nback-\nwards\nin the\nmenu",
	"deets\nnuts",
	"horse",
	"time to\nhorse\naround",
	"we\nenhorse\ngodot",
	"gun?\ngun!",
	"el horso",
	"neigh",
	"the next\nstep in\nhorse\ngaming",
	"L to the\nM to the\nA to the\nO to the",
	"why\nthe fuck\nare you\nplaying\nthis",
	"yes,\nhorse\nhell\nIS real",
	"the\nhorse is\ncastrat\n-ed",
	"flint\nand\nsteed!",
	"now with\n200%\nless\nboss\nfights!",
	"friday\nnight\nfoalin'",
	"purchase\nour new\nhorse\ngame",
	"wishlist\nyoure my\nfavorite\nperson",
	"117\ndiff-\nerent\nendings",
	"a light\nshines!",
]


func _ready() -> void:
	onInteract.connect(_onInteract)
	currentItems[0].clear()
	currentItems[1].clear()

	availableItems[2].item.origPrice = int(Global.currentGameLoop.steediumNeededToEscape / 4.0)
	availableItems[2].item.price = availableItems[2].item.origPrice

	$Mesh/Sign.mesh.text = SIGN_TEXT.pick_random()
	Global.currentShop = self

	_regenItems()
	_on_music_finished()


func _process(delta: float) -> void:
	if Global.currentGameLoop.pauseCoreGameStuff:
		$BoomBox/Music.stream_paused = true
	else:
		$BoomBox/Music.stream_paused = false
	if Global.pauseGame:
		return

	if regenItems:
		itemRegenTimer -= delta
		if itemRegenTimer <= 0.0:
			haykeeper.switch_state(Haykeeper.State.IDLE)
			_regenItems()
			Global.gameUI_RevealEvent("[color=orange]The Haykeeper[/color] has restocked it's store...")
			boughtSomething = false
			regenItems = false
	if Global.currentGameLoop.isPlayerInShop:
		if !regenItems:
			for i in range(currentItems.size()):
				if (currentItems[i])["index"] == 0:
					Global.get_node("ShopUI/Control/Item" + str(i + 1) + "/Label").text = ((currentItems[i])["desc"] as String).replace("X", str(Global.currentGameLoop.steediumBonusPrice / 2.0))
				else:
					Global.get_node("ShopUI/Control/Item" + str(i + 1) + "/Label").text = (currentItems[i])["desc"]
				Global.get_node("ShopUI/Control/Item" + str(i + 1) + "/Steedium/SteediumText").text = "[shake]" + str((currentItems[i])["price"])

				if Global.currentGameLoop.steediumCollected < (currentItems[i])["price"]:
					Global.get_node("ShopUI/Control/Item" + str(i + 1) + "/Info").text = "[center][color=red][font_size=18]Press\n[font_size=36][shake]" + ("1" if i == 0 else "2") + "\n[font_size=18]"
				else:
					Global.get_node("ShopUI/Control/Item" + str(i + 1) + "/Info").text = "[center][color=green][font_size=18]Press\n[font_size=36][shake]" + ("1" if i == 0 else "2") + "\n[font_size=18]"

			if Input.is_action_just_pressed("deets_buyItem1Shop"):
				if (Global.currentGameLoop.steediumCollected >= (currentItems[0])["price"]):
					_buyItem(0)
				else:
					$No.play()
			if Input.is_action_just_pressed("deets_buyItem2Shop"):
				if (Global.currentGameLoop.steediumCollected >= (currentItems[1])["price"]):
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


func _regenItems():
	var rand = randi_range(0, 1)
	var steediumCount = Global.currentGameLoop.steediumCollected

	var modifiedSteediumItem = steediumBonusItem.duplicate(true)
	modifiedSteediumItem["price"] = int(Global.currentGameLoop.steediumBonusPrice * SaveData.getGameSetting("items", "price_multiplier"))
	currentItems[rand] = modifiedSteediumItem

	var opposite = int(!rand)
	var shuffled_keys = availableItems.keys()
	shuffled_keys.shuffle()

	for i in range(100):
		for key in shuffled_keys:
			var base_chance = availableItems[key].chance
			var steedium_bonus = min(0.005 * steediumCount, 0.25)

			if key == 1:
				steedium_bonus += 0.3
			elif key == 2:
				if Global.currentGameLoop.pedestalsDestroyed == 4:
					steedium_bonus += 0.3
				else:
					steedium_bonus -= 0.1

			var final_chance = clamp(base_chance + steedium_bonus, 0.0, 1.0)

			if randf() < final_chance:
				if availableItems[key].item.index == 0:
					continue

				if availableItems[key].item.index == 2:
					if Global.currentGameLoop.pedestalsDestroyed == 4:
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
		haykeeper.switch_state(Haykeeper.State.IDLE)
	
	if !regenItems and !alreadyGreeted:
		$Area.audio_played.emit($Area)
		alreadyGreeted = true
	elif regenItems:
		#$Haykeeper.texture = sadTex
		if !$Haykeeper/Dialogue.playing:
			haykeeper.switch_state(Haykeeper.State.CLOSED)
			haykeeper.closed()
			$Area.audio_played.emit($Area)


func _buyItem(which):
	var boughtItem = currentItems[which]

	match boughtItem["index"]:
		0:
			boughtSomething = true
			print("Adding " + str((Global.currentGameLoop.steediumBonusPrice / 2.0)) + " to bonus, price is now " + str(Global.currentGameLoop.steediumBonusPrice * 2))
			Global.currentGameLoop.steediumBonus = (Global.currentGameLoop.steediumBonusPrice / 2.0)
			Global.currentGameLoop.steediumBonusPrice = int((Global.currentGameLoop.steediumBonusPrice * (2 * SaveData.getGameSetting("items", "price_multiplier"))))
		_:
			if Global.currentGameLoop._giveItem(boughtItem["item"], 1) != -1:
				boughtSomething = true
				availableItems[boughtItem["index"] - 1].item.price += int((availableItems[boughtItem["index"] - 1].item.origPrice * 3) * SaveData.getGameSetting("items", "price_multiplier"))
				print("item " + str(boughtItem["item"]) + " now costs: " + str(availableItems[boughtItem["index"] - 1]))
			else:
				$No.play()
				if !$Haykeeper/Dialogue.playing:
					haykeeper.switch_state(Haykeeper.State.MAD)
					haykeeper.mad()
				return

	$Cash.play()

	haykeeper.equity()
	Global.currentGameLoop._loseSteedium(boughtItem["price"])

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

	if !regenItems:
		if !boughtSomething:
			mad = true
			haykeeper.switch_state(Haykeeper.State.MAD)
			haykeeper.mad()
			$Area.audio_played.emit($Area)
	else:
		if boughtSomething:
			$Haykeeper/Dialogue.stop()
			haykeeper.switch_state(Haykeeper.State.EQUITY)
			haykeeper.equity()
			$Area.audio_played.emit($Area)
			boughtSomething = false


func _on_music_finished() -> void:
	var rand = randi() % 2
	if rand == 1:
		$BoomBox/Music.stream = load("res://Audio/Music/Canon in HORSE.mp3")
	else:
		$BoomBox/Music.stream = load("res://Audio/Music/Shop.mp3")
	$BoomBox/Music.play()
