extends CanvasLayer

func _ready() -> void:
	Global.showCrosshair = false
	Global.allowToPause = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if SaveData.gameSave.whereAt < 1:
		Global.apply_font_override_recursive(self, load("res://Fonts/Munson_Roman.otf"))
		$Control/Quit.text = "Quit"
		if Global.os == "Web":
			$Control/Quit.visible = false
			$Control/Quit.disabled = true
	else:
		SaveData._unlockAch("die")
	
	$Timer.start(2.0)
	

func _process(delta: float) -> void:
	Global.change_discord_state("dead")

func _on_timer_timeout() -> void:
	$Undertale.play()
	$Control.show()

func _on_try_again_pressed() -> void:
	Global.uiFade = true
	Global.get_node("Misc/Control/Fade").color.a = 1.0
	Global.gameUI_reveal = false
	Global.get_node("GameUI/Control").modulate.a = 0.0
	if SaveData.gameSave.whereAt > 1:
		get_tree().change_scene_to_file("res://Scenes/Level.tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/Intro.tscn")


func _on_quit_pressed() -> void:
	if SaveData.gameSave.whereAt > 1:
		get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
	else:
		get_tree().quit()
