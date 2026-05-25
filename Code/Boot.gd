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
	Global.change_discord_state("start")

func _go():
	print(SaveData.gameSave.whereAt)
	match int(SaveData.gameSave.whereAt):
		0:
			get_tree().change_scene_to_file("res://Scenes/Intro.tscn")
		1:
			get_tree().change_scene_to_file("res://Scenes/Minecraft.tscn")
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
	click.kill()
	click = create_tween()
	click.tween_property($Click/Button, "scale", Vector2(1.025, 1.025), 0.25).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
func _on_click_mouse_exited() -> void:
	click.kill()
	click = create_tween()
	click.tween_property($Click/Button, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	
func _on_click_pressed() -> void:
	_start_boot_vid()
	
