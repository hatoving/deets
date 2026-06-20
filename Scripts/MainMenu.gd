extends Control

const SECRET = ["E", "S", "R", "O", "H"]

var tween: Tween
var stuck = false
var deleteTimer = 6.0
var secProgress = []
var currentVersion = ProjectSettings.get_setting("application/config/version")


func _ready() -> void:
	Global.showCrosshair = false
	Global.allowToPause = false
	Global.enableTimer = false

	Global.gameUI_DisableHint()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	Global.uiFade = false
	Global.get_node("Misc/Control/Fade").color.a = 1.0

	if !Global.get_node("MainMenu").playing:
		Global.get_node("MainMenu").play()

	if Global.customMode:
		$Custom.show()
		$Menu.hide()
	print(SaveData.gameSave.bestTime)


func _process(delta: float) -> void:
	$Menu/Label3.text = "Best time : " + ((Global.formatTime(SaveData.gameSave.bestTime, false) if SaveData.gameSave.bestTime != 0.0 else "none, yet")) + "\nLatest custom time : " + ((Global.formatTime(SaveData.gameSave.latestCustomTime, false) if SaveData.gameSave.latestCustomTime != 0.0 else "none, yet"))
	$Menu/Label2.text = "v" + str(currentVersion) + "\nmade by hatoving\n\nhold SHIFT for %.2d seconds\nto delete save data" % deleteTimer

	if Input.is_action_pressed("deets_delete"):
		deleteTimer -= delta
		if deleteTimer <= 0.0:
			deleteFile("gameSave.dat")
			SaveData._loadGame()

			Global.get_node("MainMenu").stop()
			get_tree().change_scene_to_file("res://Scenes/Boot.tscn")
	else:
		deleteTimer = 6.0

	if Global.os == "Web":
		$Menu/Quit.visible = false
		$Menu/Quit.disabled = true

		var url = JavaScriptBridge.eval("window.location.hostname", true)
		$Menu/Label4.text = url if url != null else "no"

		if url != null and url.contains("isolated.ungrounded.net"):
			$Menu/Newgrounds.visible = true


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo():
		var secChar := OS.get_keycode_string(event.keycode).to_upper()

		if secChar.length() == 1:
			secProgress.append(secChar)
			if secProgress.size() > 5:
				secProgress.pop_front()

			if secProgress == SECRET and Global.os != "Web":
				OS.alert("Your computer is at risk of horseplay.\nShutting program down.", "Err-orse")
				get_tree().quit()


func deleteFile(fileName: String):
	var filePath = "user://" + fileName
	if FileAccess.file_exists(filePath):
		var dir = DirAccess.open("user://")
		if dir:
			var error = dir.remove(fileName)
			if error == OK:
				print("Deleted:", fileName)
			else:
				print("Failed to delete:", fileName, "Error code:", error)
		else:
			print("Failed to open user directory")
	else:
		print("File does not exist:", fileName)


func _on_journey_pressed() -> void:
	if !stuck:
		$Click.play()
		$Menu.visible = false
		SaveData.gameSettings = SaveData.defaultGameSettings.duplicate(true)
		Global.get_node("MainMenu").stop()
		Global.customMode = false
		get_tree().change_scene_to_file("res://Scenes/Level.tscn")


func _startCustom():
	$Click.play()
	$Menu.visible = false
	Global.get_node("MainMenu").stop()
	Global.customMode = true
	get_tree().change_scene_to_file("res://Scenes/Level.tscn")


func _on_credits_pressed() -> void:
	if !stuck:
		$Click.play()
		Global.uiFade = true
		Global.get_node("Misc/Control/Fade").color.a = 0.0
		$Timer.start(0.5)
		stuck = true


func _on_options_pressed() -> void:
	if !stuck:
		$Click.play()
		$Menu.visible = false
		$Options.visible = true


func _on_quit_pressed() -> void:
	if !stuck:
		$Click.play()
		get_tree().quit()


func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://Scenes/Credits.tscn")


func _on_custom_pressed() -> void:
	if !stuck:
		$Click.play()
		if !SaveData.gameSave.beatGame:
			Global.gameUI_RevealEvent("You haven't unlocked this yet.\nBeat the game to do so!", 3.0)
		else:
			$Custom.show()
			$Menu.hide()


func _on_newgrounds_pressed() -> void:
	$Newgrounds.visible = true
