extends Node3D

var disableAttrackHorse = false
var quiet = true


func _ready() -> void:
	$Sound.play()
	$AnimationPlayer.play("explode")
	if !disableAttrackHorse:
		var nearest = Global.currentLevelGen.findNearestWalkablePos(Vector2($Area.global_position.x, $Area.global_position.z))
		Global.currentGameLoop.alertHorseOfSound.emit(Vector3(nearest.x, 0.0, nearest.y))


func _process(_delta: float) -> void:
	if !quiet:
		$Sound.volume_db = -10.0
	if !$AnimationPlayer.is_playing() and !$Sound.playing:
		queue_free()
