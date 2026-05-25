extends Control

var tween: Tween

func _ready() -> void:
	SaveData.gameSave.whereAt = 1
	SaveData._saveGame()
	
	Global.uiFade = false
	Global.allowToPause = false
	Global.enableTimer = false
	
	Global.showCrosshair = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	Global.gameUI_ChangeFont("res://Fonts/Monocraft.ttf")
	Global.get_node("Misc/Control/Fade").color.a = 0.0
	
	$Menu/Logo/Label.text = Global.RANDOM_TEXT[randi_range(0, Global.RANDOM_TEXT.size() - 1)]
	start_bounce()
	
func _process(delta: float) -> void:
	if Global.os == "Web":
		$Menu/Exit.visible = false
		$Menu/Exit.disabled = true

func start_bounce():
	$Menu/Logo/Label.scale = Vector2(1.15, 1.15)
	tween = create_tween()

	tween.tween_property($Menu/Logo/Label, "scale", Vector2(1.25, 1.25), 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property($Menu/Logo/Label, "scale", Vector2(1.15, 1.15), 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	tween.tween_callback(start_bounce)

func _on_timer_timeout() -> void:
	if !$Splash.visible:
		$Splash.visible = true
		$Timer.start(3.0)
		return
	if $Splash.visible:
		$Splash.visible = false
		$Menu.visible = true
		$Menu/Music.play()
		$BG.visible = true

func _on_exit_pressed() -> void:
	$Click.play()
	get_tree().quit()

func _on_settings_pressed() -> void:
	$Click.play()
	$Menu.visible = false
	$Options.visible = true

func _on_singleplayer_pressed() -> void:
	$Click.play()
	$Menu/Music.stop()
	$Menu.visible = false
	$Loading.visible = true
	$Loading.begin()
