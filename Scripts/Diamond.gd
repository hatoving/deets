extends Node3D

var time = 0
var y_offset = 0
var orig_y = 0

var lerpToPlayer = false

func _ready() -> void:
	orig_y = position.y

func _process(delta: float) -> void:
	time += delta
	y_offset = cos(time)
	
	rotation.y += delta
	position.y = (orig_y + y_offset) / 8
	
	if lerpToPlayer and Global.currentPlayer != null:
		var lerp_pos = Vector3(Global.currentPlayer.global_position.x, position.y, Global.currentPlayer.global_position.z)
		position = position.lerp(lerp_pos, 0.2)
		if position.distance_to(lerp_pos) < 0.5:
			$Area.collected.emit($Area.collectableType, 1)
			queue_free()

func _onAboutToBeCollected() -> void:
	lerpToPlayer = true
