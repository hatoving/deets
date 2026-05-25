extends Control

func _ready() -> void:
	$Sensitivity.value = SaveData.getSetting("gameplay", "cam_sensitivity")
	$FOV.value = SaveData.getSetting("gameplay", "fov")

func _process(_delta: float) -> void:
	SaveData.setSetting("gameplay", "cam_sensitivity", $Sensitivity.value)
	SaveData.setSetting("gameplay", "fov", $FOV.value)
	
	$Speedrun.text = "Speedrun Timer : " + ("On" if SaveData.getSetting("gameplay", "timer") else "Off")
	$Leaderbaord.text = "Submit Time to Leaderboard : " + ("On" if SaveData.getSetting("gameplay", "leaderboard") else "Off")
	$Sensitivity/Label.text = "Camera Sensitivity (%.2f)" % $Sensitivity.value
	$FOV/Label.text = "Field of View (%.2f)" % $FOV.value
	
	if SaveData.gameSave.whereAt > 0:
		$Intro.show()
	else:
		$Intro.hide()

func _on_speedrun_pressed() -> void:
	get_parent().clickSFX.play()
	SaveData.setSetting("gameplay", "timer", !SaveData.getSetting("gameplay", "timer"))

func _on_intro_pressed() -> void:
	Global.get_node("MainMenu").stop()
	get_tree().change_scene_to_file("res://Scenes/Intro.tscn")

func _on_leaderbaord_pressed() -> void:
	SaveData.setSetting("gameplay", "leaderboard", !SaveData.getSetting("gameplay", "leaderboard"))
