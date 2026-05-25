extends InteractableStaticBody3D

func _ready() -> void:
	onInteract.connect(_onInteract)

func _onInteract():
	$Sound.play()
	Global.currentPlayer.goNumb = true
	Global.uiFade = true
	Global.get_node("Misc/Control/Fade").color.a = 0.0
	Global.allowToPause = false
	$Timer.start(3.0)

func _process(_delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	Global.uiFade = false
	Global.get_node("Misc/Control/Fade").color.a = 0.0
	get_tree().change_scene_to_file("res://EndingAlt.tscn")
