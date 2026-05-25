extends Node
class_name GameLoop

var dohorseEvents = true
var horseSpawnTimer = 20
var horseSpawnIndex = 0
var horseAmount = 1

var diamondsCollected = 0
var diamondRegenDuration = 60
var diamondRegenTimer = 0

var diamondBonus = 0

var diamondBonusAmount = 0
var diamondLoseAmount = 0
var diamondModTimer = 0.1

var diamondBonusPrice = 2
var isPlayerInShop = false

var diamondsNeededToEscape = -1

var valuableHorseItemsDestroyed = 0
var valuableHorseItemAmount = 4
var valuableHorseItemDiamondMult = 0.55

var speedRunTimer = 0.0

var start = false
var endGame = false
var endingGame = false
var spooky = false

var ambienceDbTarget = 5.0
var ambienceSpookyDbTarget = -80.0
var ambienceSpookierDbTarget = 0.0

var fogDensityTarget = 0.262
var fogColorTarget = Color.BLACK

var pauseCoreGameStuff = true

var items = {
	"" : {
		"tex" : null,
		"name" : "Nothing"
	},
	"horseFood" : {
		"tex" : preload("res://Sprites/HorseFood.png"),
		"name" : "Horse Food"
	},
	"hammer" : {
		"tex" : preload("res://Sprites/Hammer.png"),
		"name" : "Hammer"
	},
	"gun" : {
		"tex" : preload("res://Sprites/Gun.png"),
		"name" : "Gun"
	}
}

var itemsInInventory = {
	0 : {
		item = "",
		stack = 0,
	},
	1 : {
		item = "",
		stack = 0,
	}
}
var currentlySelectedItem = 0
var endTimer = 5.0

var horseScene = preload("res://Scenes/LevelGen/Structures/Horse.tscn")

signal alertHorseOfSound(Vector3)
signal rageHorse()
signal raiseSpeedMultHorse(float)

func pickHorseSpawnPoint() -> Vector3:
	var pp = Global.currentPlayer.global_position
	for i in range(200):
		var wow = Vector3(randi_range(0, Global.currentMazeSize.x), 0.0, randi_range(0, Global.currentMazeSize.y))
		if wow.distance_to(pp) >= 50.0:
			print("spawning horseScene at " + str(wow) + "& distance to player is " + str(wow.distance_to(pp)))
			var walkable = Global.currentLevelGen.findNearestWalkablePos(Vector2(wow.x, wow.z))
			var middle = Global.currentLevelGen.getPointMiddle(walkable)
			return middle
	print("spawning horseScene with fallback conditions")
	var middle = Global.currentLevelGen.getPointMiddle(Vector2(Global.currentMazeSize.x,Global.currentMazeSize.y))
	return middle

func launchHorse(inWhere):
	var horse = horseScene.instantiate() as Node3D
	horse.position = pickHorseSpawnPoint()
	inWhere.add_child(horse)
	Global.currentHorse = horse

func _playFinal():
	$AmbienceEvenSpookier.play()

func _giveItem(what, howMuch) -> int:
	var ret = -1
	for i in itemsInInventory:
		if itemsInInventory[i].item == what:
			itemsInInventory[i].stack += howMuch
			Global.gameUI_CollectItem(i)
			ret = 1
			break
		elif itemsInInventory[i].item == "":
			itemsInInventory[i].item = what
			itemsInInventory[i].stack += howMuch
			Global.gameUI_CollectItem(i)
			ret = 1
			break
		else:
			ret = -1
	if ret != -1:
		Global.currentPlayer._playPop()
	return ret

func _loseItem(what, howMuch) -> bool:
	var ret = -1
	for i in itemsInInventory:
		if itemsInInventory[i].item == what:
			if itemsInInventory[i].stack < 2:
				itemsInInventory[i].item = ""
			else:
				itemsInInventory[i].item = what
			itemsInInventory[i].stack -= howMuch
			Global.gameUI_CollectItem(i)
			ret = 1
			break
		else:
			ret = -1
	if ret != -1:
		Global.currentPlayer._playPopLowPitched()
	return ret

func _ready() -> void:
	SaveData.gameSave.whereAt = 2
	SaveData._saveGame()
	
	Global.currentGameLoop = self
	Global.allowToPause = true
	Global.showCrosshair = true
	
	diamondsNeededToEscape = (Global.currentMazeSize.x * Global.currentMazeSize.y) * 3
	print("Gonna need " + str(diamondsNeededToEscape) + " to escape!")
	
	diamondRegenTimer = diamondRegenDuration
	
	valuableHorseItemAmount = SaveData.gameSettings["items.valuable_amount"]
	itemsInInventory = SaveData.gameSettings["items.start"]
	horseSpawnTimer = SaveData.getGameSetting("horse", "spawn_duration")
	horseAmount = SaveData.getGameSetting("horse", "amount")
	
	diamondsCollected = SaveData.getGameSetting("player", "diamonds_collected")
	diamondBonus = SaveData.getGameSetting("player", "diamond_bonus_collected")
	dohorseEvents = SaveData.getGameSetting("horse", "spawn")
	
	Global.uiFade = false
	Global.get_node("Misc/Control/Fade").color.a = 1.0
	
func _giveDiamonds(howMuch):
	Global.gameUI_CollectDiamond(howMuch)
	diamondsCollected += howMuch
	diamondBonusAmount += diamondBonus
	diamondModTimer = randf_range(0.0, 0.05)
	
func _loseDiamonds(howMuch):
	diamondsCollected -= howMuch
	Global.gameUI_LoseDiamond(howMuch)
	Global.currentPlayer._playPopLowPitched()

func _process(delta: float) -> void:
	if SaveData.getSetting("gameplay", "timer"):
		Global.enableTimer = true
	else:
		Global.enableTimer = false
	
	if valuableHorseItemsDestroyed > (valuableHorseItemAmount - 2) and !spooky and !SaveData.getGameSetting("maze", "disable_spooky"):
		ambienceDbTarget = -80.0
		ambienceSpookyDbTarget = 0.0
		fogColorTarget = Color.WEB_MAROON
		spooky = true
	
	if endingGame:
		$Wind.volume_db = lerp($Wind.volume_db, 0.0, 8.0 * delta)
		ambienceSpookierDbTarget = -80.0
		fogColorTarget = Color.BLACK
		
		endTimer -= delta
		if endTimer <= 0.0:
			Global.finalTime = speedRunTimer
			get_tree().change_scene_to_file("res://Scenes/Ending.tscn")
	
	if Global.currentPlayer:
		if Global.currentPlayer.position.y >= 0.0 and !start:
			start = true
			pauseCoreGameStuff = false
			Global.uiFade = false
			Global.gameUI_reveal = true
			if SaveData.gameSave.get("firstTime", true):
				Global._showHowToPlayStraight()
				SaveData.gameSave["firstTime"] = false
				SaveData._saveGame()
			Global.currentStartFence.toggleClose()
		if Global.currentPlayer.position.y <= -1.5 and endGame and !endingGame:
			endingGame = true
			Global.allowToPause = false
			Global.gameUI_reveal = false
			Global.uiFade = true
			Global.currentStartFence.toggleClose()
			
	($WorldEnvironment.environment as Environment).fog_density = lerp(($WorldEnvironment.environment as Environment).fog_density, fogDensityTarget, 0.2 * delta)
		
	if Global.pauseGame:
		return
	
	speedRunTimer += delta
	
	if pauseCoreGameStuff:
		return
	
	$Ambience.volume_db = lerp($Ambience.volume_db, ambienceDbTarget, 5.0 * delta)
	$AmbienceSpooky.volume_db = lerp($AmbienceSpooky.volume_db, ambienceSpookyDbTarget, 5.0 * delta)
	$AmbienceEvenSpookier.volume_db = lerp($AmbienceEvenSpookier.volume_db, ambienceSpookierDbTarget, 5.0 * delta)
	($WorldEnvironment.environment as Environment).fog_light_color = lerp(($WorldEnvironment.environment as Environment).fog_light_color, fogColorTarget, 5.0 * delta)
	
	if Input.is_action_just_pressed("deets_selectItem1"):
		currentlySelectedItem = 0
		Global._showItemName()
	if Input.is_action_just_pressed("deets_selectItem2"):
		currentlySelectedItem = 1
		Global._showItemName()
		
	if Input.is_action_just_pressed("deets_interact") and !Global.currentPlayer.interactingWithSomethingElse and !Global.currentPlayer.goNumb:
		if itemsInInventory[currentlySelectedItem].item == "gun":
			_loseItem("gun", 1)
			($WorldEnvironment.environment as Environment).fog_light_color = Color.NAVAJO_WHITE
			Global.currentPlayer._onGun()
	
	Global.get_node("GameUI/Control/Diamonds/Text").text = str(diamondsCollected)
	if diamondBonusAmount > 0:
		diamondModTimer -= delta
		if diamondModTimer <= 0.0:
			if diamondBonusAmount > 64:
				diamondsCollected += 64
				diamondBonusAmount -= 64
				Global.currentPlayer._playPop()
				Global.gameUI_CollectDiamond(64)
				diamondModTimer = 0
			elif diamondBonusAmount > 128:
				diamondsCollected += 128
				diamondBonusAmount -= 128
				Global.currentPlayer._playPop()
				Global.gameUI_CollectDiamond(128)
				diamondModTimer = 0
			else:
				diamondModTimer = randf_range(0.0, 0.02)
				diamondBonusAmount -= 1
				diamondsCollected += 1
				Global.currentPlayer._playPop()
				Global.gameUI_CollectDiamond(1)
		
	if dohorseEvents:
		horseSpawnTimer -= delta
		if horseSpawnTimer <= 0:
			if SaveData.getGameSetting("horse", "amount") > 1:
				Global.gameUI_RevealEvent("A [color=orange]horse[/color] has entered.")
			else:
				Global.gameUI_RevealEvent("The [color=orange]horse[/color] is here.")
			horseAmount -= 1
			launchHorse($LevelGen)
			if horseAmount <= 0:
				dohorseEvents = false
			else:
				horseSpawnTimer = SaveData.getGameSetting("horse", "spawn_duration")
	diamondRegenTimer -= delta
	if diamondRegenTimer <= 0:
		$LevelGen.placeDiamonds()
		Global.gameUI_RevealEvent("Placing some [color=cyan]diamonds[/color] around...")
		diamondRegenDuration += randf_range(4, 8)
		print("Diamond regen takes " + str(diamondRegenDuration) + " seconds now...")
		diamondRegenTimer = diamondRegenDuration
	
	Global.change_discord_state("game")
