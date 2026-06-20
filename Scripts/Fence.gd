class_name Fence
extends StaticBody3D

var close = false


func _ready() -> void:
	Global.currentStartFence = self


func _process(delta: float) -> void:
	if Global.pauseGame:
		$Close.stream_paused = true
		$Open.stream_paused = true
	else:
		$Close.stream_paused = false
		$Open.stream_paused = false

	if close:
		position.x += delta * 3
	else:
		position.x -= delta * 3
	position.x = clamp(position.x, -1.0, 0.0)


func toggleClose():
	close = !close
	if close:
		$Tube.visible = false
		$Close.play()
	else:
		$Tube.visible = true
		$Open.play()
