extends Node

@onready var click = create_tween()


func _ready() -> void:
	Global.showCrosshair = false
	Global.allowToPause = false
	if Global.os == "Web":
		print("wold wide web")
		var url = JavaScriptBridge.eval("window.location.hostname", true)
		if url != null and url.contains("isolated.ungrounded.net"):
			NG.sign_in()

		$Control.hide()
		$Click.show()
		$Click/Button.pivot_offset = $Click/Button.size / 2
	else:
		_start_boot_vid()


func _go():
	print(SaveData.gameSave.whereAt)
	match int(SaveData.gameSave.whereAt):
		0:
			get_tree().change_scene_to_file("res://Scenes/Intro.tscn")
		1:
			get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
		2:
			get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")


func _start_boot_vid() -> void:
	$Click.hide()
	$Click.queue_free()
	$Control.show()
	$Control/Video.play()


func _on_video_finished() -> void:
	$Control/Text.show()
	$Timer.start(2.0)


func _on_timer_timeout() -> void:
	print("ligma")
	_go()


func _on_click_mouse_entered() -> void:
	$Click/Button.modulate = Color("ff930d")
	$Click/Button.scale = Vector2(1.025, 1.025)


func _on_click_mouse_exited() -> void:
	$Click/Button.modulate = Color.WHITE
	$Click/Button.scale = Vector2.ONE


func _on_click_pressed() -> void:
	_start_boot_vid()
