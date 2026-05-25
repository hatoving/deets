extends Node

var currentPlayer : CharacterBody3D
var currentStartFence : Fence
var currentHorse : CharacterBody3D

var currentLevelGen : LevelGen
var currentGameLoop : GameLoop
var currentShop : InteractableStaticBody3D
var currentMazeSize : Vector2
var currentMazeData

var os = OS.get_name()

var lerpEngineTimeScaleTarget = 1.0

var shopUI_XTarget = -342.0

var shopUI_SteediumAdd = 0
var shopUI_SteediumAddTimer = 0.0

var gameUI_eventTimer = 0.0
var gameUI_eventAlphaTarget = 0.0

var gameUI_reveal = false
var uiFade = false

var inShopUI = false

var allowToPause = true
var pauseGame = false

var showCrosshair = true
var enableTimer = false
var goStraightToUnpauseFromHTP = false

var finalTime = 70
var customMode = false

@onready var lastMenu = $PauseUI/Main

@onready var hotbarSelectedTex = preload("res://Sprites/Inventory/hotbar_1.png")
@onready var hotbarNotSelectedTex = preload("res://Sprites/Inventory/hotbar_0.png")

@onready var gameUI : CanvasLayer = $GameUI
@onready var shopUI : CanvasLayer = $ShopUI
@onready var miscUI : CanvasLayer = $Misc

func gameUI_ChangeFont(font_path: String):
	var new_font = load(font_path)
	apply_font_override_recursive(self, new_font)

func apply_font_override_recursive(node: Node, font: Font):
	if node is Control and !node.get_path().get_concatenated_names().contains("Achievement"):
		var control_node := node as Control
		control_node.add_theme_font_override("font", font)
		control_node.add_theme_font_override("normal_font", font)

	for child in node.get_children(true):
		apply_font_override_recursive(child, font)

func gameUI_CollectSteedium(howMuch):
	$GameUI/Control/Steedium.scale = Vector2(0.5, 1.5)
	$GameUI/Control/SteediumAdd.modulate.a = 1.0
	if shopUI_SteediumAdd < 0:
		shopUI_SteediumAdd = 0
	shopUI_SteediumAdd += howMuch
	$GameUI/Control/SteediumAdd.text = "[color=green]+" + str(shopUI_SteediumAdd)
	shopUI_SteediumAddTimer = 3

func gameUI_CollectItem(which):
	$GameUI.get_node("Control/Hotbar" + str(which) + "/Tex").scale = Vector2(0.25, 1.0)
	
func gameUI_LoseSteedium(howMuch):
	$GameUI/Control/Steedium.scale = Vector2(0.5, 1.5)
	$GameUI/Control/SteediumAdd.modulate.a = 1.0
	if shopUI_SteediumAdd > 0:
		shopUI_SteediumAdd = 0
	shopUI_SteediumAdd -= howMuch
	$GameUI/Control/SteediumAdd.text = "[color=red]" + str(shopUI_SteediumAdd)
	shopUI_SteediumAddTimer = 3
	
func gameUI_RevealEvent(what, duration : float = 3.0):
	$Misc/Control/EventText.text = what
	
	$Misc/Control/EventText.modulate.a = 0.0
	gameUI_eventAlphaTarget = 1.0
	gameUI_eventTimer = duration
	#$Misc/Control/EventText/AnimationPlayer.stop()
	#$Misc/Control/EventText/AnimationPlayer.play("event")
	
	$Misc/Control/EventText/Boom.pitch_scale = randf_range(0.6, 1.4)
	$Misc/Control/EventText/Boom.play()
	
func gameUI_EnableHint(hint):
	$Misc/Control/HintText.text = hint

func gameUI_DisableHint():
	$Misc/Control/HintText.text = ""
	
func shopUI_Toggle():
	$ShopUI.visible = !$ShopUI.visible
	inShopUI = !inShopUI
	if $ShopUI.visible:
		shopUI_XTarget = 88.0
	else:
		shopUI_XTarget = -342.0
		
func _showItemName():
	$GameUI/Control.get_node("ItemDesc" + str(int(currentGameLoop.currentlySelectedItem))).modulate.a = 1.0
	
func _showHowToPlayStraight():
	_togglePause()
	$PauseUI/HowToPlay.show()
	$PauseUI/Main.hide()
	goStraightToUnpauseFromHTP = true

func formatTime(timeSeconds: float, addText : bool = true) -> String:
	var total_milliseconds = int(timeSeconds * 1000)
	var hours = total_milliseconds / 3600000.0
	var minutes = (total_milliseconds % 3600000) / 60000.0
	var seconds = (total_milliseconds % 60000) / 1000.0
	var milliseconds = total_milliseconds % 1000
	
	return ("%02d:%02d:%02d:%02d" % [hours, minutes, seconds, milliseconds]) + (("\nCUSTOM" if customMode else "") if addText else "")
	
func _togglePause():
	pauseGame = !pauseGame
	if pauseGame:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		setLerpTimeScale(0.0)
		$PauseUI.visible = true
		if lastMenu:
			lastMenu.visible = true
	else:
		SaveData._saveSettings()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		Engine.time_scale = 0.01
		setLerpTimeScale(1.0)
		$PauseUI.visible = false
		if lastMenu:
			lastMenu.visible = false

func setLerpTimeScale(target):
	lerpEngineTimeScaleTarget = target

func updatePitch(bus_name: String, effect_index: int) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	var effect := AudioServer.get_bus_effect(bus_index, effect_index) as AudioEffectPitchShift
	effect.pitch_scale = lerp(effect.pitch_scale, lerpEngineTimeScaleTarget, 0.3)

func _process(delta: float) -> void:
	if SaveData.gameSave.whereAt < 1:
		if Global.os == "Web":
			$PauseUI/Main/Exit.visible = false
			$PauseUI/Main/Exit.disabled = true
	elif SaveData.gameSave.whereAt > 1:
		$PauseUI/Main/Exit.visible = true
		$PauseUI/Main/Exit.disabled = false
	
	if !$PauseUI/HowToPlay.visible:
		$PauseUI/HowToPlay/RichTextLabel.position.y = 40.0
	else:
		$PauseUI/HowToPlay/RichTextLabel.position.y = lerp($PauseUI/HowToPlay/RichTextLabel.position.y, 55.0, 0.2)
		
	if SaveData.gameSave.whereAt > 0:
		$PauseUI/Main/HowToPlay.show()
	else:
		$PauseUI/Main/HowToPlay.hide()
	
	if Input.is_action_just_pressed("deets_pause") and allowToPause and !goStraightToUnpauseFromHTP:
		_togglePause()
	
	if get_tree().current_scene:
		if get_tree().current_scene.name == "Level" or get_tree().current_scene.name == "Intro":
			$PauseUI/Options/Game/Horsecraft.disabled = true
			$PauseUI/Options/Game/Intro.disabled = true
		else:
			$PauseUI/Options/Game/Horsecraft.disabled = false
			$PauseUI/Options/Game/Intro.disabled = false
	
	if !pauseGame and (currentPlayer != null):
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	Engine.time_scale = lerp(Engine.time_scale, lerpEngineTimeScaleTarget, 20.0 * delta)
	if abs(Engine.time_scale - lerpEngineTimeScaleTarget) < 0.05:
		Engine.time_scale = lerpEngineTimeScaleTarget
	Engine.time_scale = clamp(Engine.time_scale, 0.0, 1.0)
		
	$Misc/Control/Crosshair.visible = showCrosshair
	$Misc/Control/Timer.visible = enableTimer
	
	updatePitch("SFX", 0)
	updatePitch("Music", 0)
	updatePitch("Ambience", 0)
	
	if uiFade:
		$Misc/Control/Fade.color.a += delta * 2
	else:
		$Misc/Control/Fade.color.a -= delta * 2
	$Misc/Control/Fade.modulate.a  = clamp($Misc/Control/Fade.modulate.a, 0.0, 1.0)
	
	if $GameUI.visible:
		if gameUI_reveal:
			$GameUI/Control.modulate.a = lerp ($GameUI/Control.modulate.a, 1.0, 3.0 * delta)
		else:
			$GameUI/Control.modulate.a = lerp ($GameUI/Control.modulate.a, 0.0, 3.0 * delta)
		
		$Misc/Control/EventText.modulate.a = lerp($Misc/Control/EventText.modulate.a, gameUI_eventAlphaTarget, 12.0 * delta)
		if gameUI_eventTimer > 0.0:
			gameUI_eventTimer -= delta
			gameUI_eventAlphaTarget = 1.0
		if gameUI_eventTimer <= 0.0:
			gameUI_eventAlphaTarget = 0.0
		
		if currentGameLoop:
			$Misc/Control/Timer.text = str(formatTime(currentGameLoop.speedRunTimer))
		
		$GameUI/Control/Steedium.scale = $GameUI/Control/Steedium.scale.lerp(Vector2(1.0, 1.0), 8.0 * delta)
		$GameUI/Control/SteediumAdd.modulate.a = lerp($GameUI/Control/SteediumAdd.modulate.a, 0.0, .5 * delta)
		if shopUI_SteediumAddTimer > 0:
			shopUI_SteediumAddTimer -= delta
		elif shopUI_SteediumAddTimer <= 0:
			shopUI_SteediumAdd = 0
			
		if currentGameLoop != null:
			$GameUI/Control.get_node("Hotbar" + str(int(currentGameLoop.currentlySelectedItem))).texture = hotbarSelectedTex
			$GameUI/Control.get_node("Hotbar" + str(int(!currentGameLoop.currentlySelectedItem))).texture = hotbarNotSelectedTex
			
			for i in range(2):
				$GameUI/Control.get_node("ItemDesc" + str(i)).modulate = lerp($GameUI/Control.get_node("ItemDesc" + str(i)).modulate, Color.TRANSPARENT, 1.0 * delta)

				$GameUI/Control.get_node("ItemDesc" + str(i)).text = ((currentGameLoop.items[(currentGameLoop.itemsInInventory[i])["item"]]))["name"]
				$GameUI/Control.get_node("Hotbar" + str(i) + "/Tex").texture = ((currentGameLoop.items[(currentGameLoop.itemsInInventory[i])["item"]]))["tex"]
				$GameUI/Control.get_node("Hotbar" + str(i) + "/Tex").scale = $GameUI/Control.get_node("Hotbar" + str(i) + "/Tex").scale.lerp(Vector2(0.5, 0.5), 8.0 * delta)
				$GameUI/Control.get_node("ItemStack" + str(i)).text = str((currentGameLoop.itemsInInventory[i])["stack"])
	
	$PauseUI.visible = pauseGame
	
	if $PauseUI.visible:
		$PauseUI/BG.color.a = lerp($PauseUI/BG.color.a, .45, 0.2)
		if $PauseUI/Main.visible:
			$PauseUI/Main/Resume.position.x = lerp($PauseUI/Main/Resume.position.x, 52.0, 0.2)
			$PauseUI/Main/Options.position.x = lerp($PauseUI/Main/Options.position.x, 52.0, 0.2)
			$PauseUI/Main/Exit.position.x = lerp($PauseUI/Main/Exit.position.x, 52.0, 0.2)
		if $PauseUI/Options.visible:
			$PauseUI/Options/Back.position.x = lerp($PauseUI/Options/Back.position.x, 27.0, 0.2)
	else:
		$PauseUI/BG.color.a = 0.0
	
	if !$PauseUI.visible:
		$PauseUI/Main/Resume.position.x = 10.0
		$PauseUI/Main/Options.position.x = 0.0
		$PauseUI/Main/Exit.position.x = -10.0
		
	if !$PauseUI/Options.visible:
		$PauseUI/Options/Back.position.x = 0.0
				
	$ShopUI/Control/Item1.position.x = lerp($ShopUI/Control/Item1.position.x, shopUI_XTarget, 8.0 * delta)
	$ShopUI/Control/Item2.position.x = $ShopUI/Control/Item1.position.x
	$ShopUI/Control/HintText.position.x = $ShopUI/Control/Item1.position.x + 92.0
	$ShopUI/Control/HintText2.position.x = $ShopUI/Control/Item1.position.x + 311.0
	
	$ShopUI/OutOfOrder/Info.position.x = $ShopUI/Control/Item1.position.x
	$ShopUI/OutOfOrder/HintText2.position.x = $ShopUI/Control/Item1.position.x + 311.0

func _onPauseMain_ResumePressed() -> void:
	lastMenu = $PauseUI/Main
	$PauseUI.visible = false
	Engine.time_scale = 0.01
	_togglePause()

func _onPauseOptions_BackPressed() -> void:
	lastMenu = $PauseUI/Main
	$PauseUI/Options.hide()
	$PauseUI/Main.show()

func _onPauseMain_OptionsPressed() -> void:
	lastMenu = $PauseUI/Options
	$PauseUI/Options.show()
	$PauseUI/Main.hide()

func _on_exit_pressed() -> void:
	lastMenu = $PauseUI/Main
	if SaveData.gameSave.whereAt < 2:
		get_tree().quit()
	else:
		_togglePause()
		gameUI_reveal = false
		$GameUI/Control.modulate.a = 0.0
		get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func _on_backHTP_pressed() -> void:
	lastMenu = $PauseUI/Main
	if goStraightToUnpauseFromHTP:
		Engine.time_scale = 0.01
		_togglePause()
		SaveData._saveGame()
		goStraightToUnpauseFromHTP = false
		$PauseUI/HowToPlay.hide()
		return
	$PauseUI/HowToPlay.hide()
	$PauseUI/Main.show()

func _on_how_to_play_pressed() -> void:
	lastMenu = $PauseUI/HowToPlay
	$PauseUI/HowToPlay.show()
	$PauseUI/Main.hide()

func _on_options_on_exit() -> void:
	lastMenu = $PauseUI/Main
