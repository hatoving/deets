extends Control

var stuck = false
var arrowOn = true
const ARROW_MAX = 1.0
var arrowTime = ARROW_MAX

func _ready() -> void:
	Global.showCrosshair = false
	Global.allowToPause = false
	
	Global.uiFade = false
	Global.get_node("Misc/Control/Fade").color.a = 1.0
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if !Global.get_node("MainMenu").playing:
		Global.get_node("MainMenu").play()

func _process(delta: float) -> void:
	arrowTime -= delta
	
	if arrowTime <= 0:
		arrowOn = !arrowOn
		arrowTime = ARROW_MAX
	
	if arrowOn:
		$Arrow.show()
	else:
		$Arrow.hide()

func _on_back_pressed() -> void:
	if !stuck:
		$Click.play()
		Global.uiFade = true
		Global.get_node("Misc/Control/Fade").color.a = 0.0
		$Timer.start(0.5)
		stuck = true


func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://MainMenu.tscn")


func _on_text_meta_clicked(meta: Variant) -> void:
	$Click.play()
	print("opening " + str(meta))
	OS.shell_open(str(meta))
