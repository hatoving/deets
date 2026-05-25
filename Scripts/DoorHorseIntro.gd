extends InteractableStaticBody3D

var explosionScene = preload("res://Scenes/LevelGen/Explosion.tscn")

@export var introManager : Node

func _ready() -> void:
	onInteract.connect(_onInteract)
	
func _onInteract():
	if introManager.playerHasKey:
		var explo = explosionScene.instantiate()
		explo.disableAttrackHorse = true
		explo.quiet = false
		get_parent().add_child(explo)
		explo.global_position = global_position
		explo.position.x += 3.0
		explo.position.y -= 0.5
		explo.scale *= 8
		queue_free()
	
func _process(_delta: float) -> void:
	if introManager.playerHasKey:
		hint = "press [color=yellow]Left Mouse Button[/color] to open"
	else:
		hint = "I need a [color=orange]key[/color] to open this..."
