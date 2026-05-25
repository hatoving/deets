extends CanvasLayer

@export var menu : CanvasLayer
@export var controller : Control

func _ready():
	_updateValuesFromCurrentSetting()
	
func _process(delta: float) -> void:
	$Pag1/Width/Label.text = "Maze Width (" + str(SaveData.getGameSetting("maze", "width")) + ")"
	$Pag1/Height/Label.text = "Maze Height (" + str(SaveData.getGameSetting("maze", "height")) + ")"
	$Pag1/Ratio/Label.text = "Steedium Sp. Ratio (" + str(SaveData.getGameSetting("maze", "steedium_spawn_ratio")) + ")"
	$Pag1/Valuable/Label.text = "Pedestal Amount (" + str(SaveData.getGameSetting("items", "valuable_amount")) + ")"
	$Pag1/PlayerSpeed/Label.text = "Player Spd. Mult. (" + str(SaveData.getGameSetting("player", "speed_multiplier")) + "x)"
	$Pag1/HorseSpeed/Label.text = "Horse Spd. Mult (" + str(SaveData.getGameSetting("horse", "speed_multiplier")) + "x)"
	$Pag1/Spooky.text = "Disable \"Red Fog\" Mode : " + ("Yes" if SaveData.getGameSetting("maze", "disable_spooky") else "No")
	
	$Pag2/HorseSpawn/Label.text = "Horse Spawn Dur. (%.2ds)" % SaveData.getGameSetting("horse", "spawn_duration")
	$Pag2/ItemMult/Label.text = "Item Price Mult. (" + str(SaveData.getGameSetting("items", "price_multiplier")) + "x)"
	$Pag2/SpawnHorse.text = "Spawn Horse at All : " + ("Yes" if SaveData.getGameSetting("horse", "spawn") else "No")
	$Pag2/HorseAmount/Label.text = "Horse Amount (" + str(SaveData.getGameSetting("horse", "amount")) + ")"

func _getItemFromIndex(index):
	match index:
		0:
			return ""
		1:
			return "horseFood"
		2:
			return "hammer"
		3:
			return "gun"
	return ""
	
func _getItemFromName(index):
	match index:
		"":
			return 0
		"horseFood":
			return 1
		"hammer":
			return 2
		"gun":
			return 3
	return 0

func _updateValuesFromCurrentSetting():
	$Pag1/Width.value = SaveData.getGameSetting("maze", "width")
	$Pag1/Height.value = SaveData.getGameSetting("maze", "height")
	$Pag1/Ratio.value = SaveData.getGameSetting("maze", "steedium_spawn_ratio")
	
	$Pag1/Valuable.value = SaveData.getGameSetting("items", "valuable_amount")
	
	$Pag1/Item1/TextEdit.text = str((SaveData.getGameSetting("items", "start"))[0].stack)
	$Pag1/Item1/Option.selected = _getItemFromName(((SaveData.getGameSetting("items", "start"))[0].item))
	$Pag1/Item2/TextEdit.text = str((SaveData.getGameSetting("items", "start"))[1].stack)
	$Pag1/Item2/Option.selected = _getItemFromName(((SaveData.getGameSetting("items", "start"))[1].item))
	
	$Pag1/PlayerSpeed.value = SaveData.getGameSetting("player", "speed_multiplier")
	$Pag1/HorseSpeed.value = SaveData.getGameSetting("horse", "speed_multiplier")
	
	$Pag1/Spooky.button_pressed = SaveData.getGameSetting("maze", "disable_spooky")
	
	$Pag2/SteediumCollected.text = str( SaveData.getGameSetting("player", "steedium_collected"))
	$Pag2/SteediumBonus.text = str( SaveData.getGameSetting("player", "steedium_bonus_collected"))
	
	$Pag2/ItemMult.value = SaveData.getGameSetting("items", "price_multiplier")
	
	$Pag2/HorseSpawn.value = SaveData.getGameSetting("horse", "spawn_duration")
	$Pag2/SpawnHorse.button_pressed = SaveData.getGameSetting("horse", "spawn")
	$Pag2/HorseAmount.value = SaveData.getGameSetting("horse", "amount")

func _on_text_edititem2_text_changed(new_text: String) -> void:
	if $Pag1/Item2/Option.selected == 0:
		$Pag1/Item2/TextEdit.text = "0"
	(SaveData.gameSettings["items.start"])[1].stack = int(new_text)

func _on_text_edititem1_text_changed(new_text: String) -> void:
	if $Pag1/Item1/Option.selected == 0:
		$Pag1/Item1/TextEdit.text = "0"
	(SaveData.gameSettings["items.start"])[0].stack = int(new_text)

func _on_reset_pressed() -> void:
	SaveData.gameSettings = SaveData.defaultGameSettings.duplicate(true)
	_updateValuesFromCurrentSetting()

func _on_width_value_changed(value: float) -> void:
	SaveData.setGameSetting("maze", "width", int(value))

func _on_height_value_changed(value: float) -> void:
	SaveData.setGameSetting("maze", "height", int(value))

func _on_ratio_value_changed(value: float) -> void:
	SaveData.setGameSetting("maze", "steedium_spawn_ratio", value)

func _on_valuable_value_changed(value: float) -> void:
	SaveData.setGameSetting("items", "valuable_amount", int(value))

func _on_player_speed_value_changed(value: float) -> void:
	SaveData.setGameSetting("player", "speed_multiplier", value)

func _on_horse_speed_value_changed(value: float) -> void:
	SaveData.setGameSetting("horse", "speed_multiplier", value)

func _on_option_item1_selected(index: int) -> void:
	(SaveData.gameSettings["items.start"])[0].item = _getItemFromIndex(index)
	if index != 0:
		(SaveData.gameSettings["items.start"])[0].stack = 1
		_updateValuesFromCurrentSetting()

func _on_option_item2_selected(index: int) -> void:
	(SaveData.gameSettings["items.start"])[1].item = _getItemFromIndex(index)
	if index != 0:
		(SaveData.gameSettings["items.start"])[1].stack = 1
		_updateValuesFromCurrentSetting()

func _on_spooky_pressed() -> void:
	SaveData.setGameSetting("maze", "disable_spooky", !SaveData.getGameSetting("maze", "disable_spooky"))

func _on_back_pressed() -> void:
	_updateValuesFromCurrentSetting()
	menu.show()
	self.hide()

func _on_go_pressed() -> void:
	Global.customMode = true
	self.hide()
	
	if (SaveData.getGameSetting("items", "start"))[0].stack <= 0:
		if (SaveData.getGameSetting("items", "start"))[0].item == "":
			SaveData.getGameSetting("items", "start")[0].stack = 0
		else:
			SaveData.getGameSetting("items", "start")[0].stack = 1
	elif (SaveData.getGameSetting("items", "start"))[0].stack > 0:
		if (SaveData.getGameSetting("items", "start"))[0].item == "":
			SaveData.getGameSetting("items", "start")[0].stack = 0
	if (SaveData.getGameSetting("items", "start"))[1].stack <= 0:
		if (SaveData.getGameSetting("items", "start"))[1].item == "":
			SaveData.getGameSetting("items", "start")[1].stack = 0
		else:
			SaveData.getGameSetting("items", "start")[1].stack = 1
	elif (SaveData.getGameSetting("items", "start"))[1].stack > 0:
		if (SaveData.getGameSetting("items", "start"))[1].item == "":
			SaveData.getGameSetting("items", "start")[1].stack = 0
	
	controller._startCustom()

func _on_horse_spawn_value_changed(value: float) -> void:
	SaveData.setGameSetting("horse", "spawn_duration", value)

func _on_steedium_collected_text_changed(new_text: String) -> void:
	SaveData.setGameSetting("player", "steedium_collected", int(new_text))

func _on_steedium_bonus_text_changed(new_text: String) -> void:
	SaveData.setGameSetting("player", "steedium_bonus_collected", int(new_text))

func _on_item_mult_value_changed(value: float) -> void:
	SaveData.setGameSetting("items", "price_multiplier", value)

func _on_spawn_horse_pressed() -> void:
	SaveData.setGameSetting("horse", "spawn", !SaveData.getGameSetting("horse", "spawn"))

func _on_left_pressed() -> void:
	$Pag2.hide()
	$Pag1.show()

func _on_right_pressed() -> void:
	$Pag2.show()
	$Pag1.hide()

func _on_horse_amount_value_changed(value: float) -> void:
	SaveData.setGameSetting("horse", "amount", int(value))
