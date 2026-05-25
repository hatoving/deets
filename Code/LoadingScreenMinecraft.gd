extends Control

var do = false
var done = false

@export var bg : Control
@export var pop : AudioStreamPlayer

func begin():
	do = true

func _process(delta: float) -> void:
	if do:
		$HSlider.value += 0.5

		if $HSlider.value >= 100.0:
			$HSlider.value = 100.0
			pop.play()
			$Timer2.start(3.0)
			do = false

func _on_timer_2_timeout() -> void:
	if !done:
		done = true
		bg.visible = false
		self.visible = false
		$Timer2.start(3.0)
	else:
		Global.uiFade = true
		Global.get_node("Misc/Control/Fade").color.a = 1.0
		get_tree().change_scene_to_file("res://Scenes/Level.tscn")
