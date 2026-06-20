extends InteractableStaticBody3D

@export var intro: Node


func _ready() -> void:
	onInteract.connect(_onInteract)


func _onInteract():
	Global.gameUI_RevealEvent("Picked up a key.")
	$Sound.pitch_scale = randf_range(0.8, 1.2)
	$Sound.play()
	intro.playerHasKey = true
	visible = false
	isInteractable = false
