extends Node

@export var playerHasKey = false

var beginIndex = -1
var nextDuration = 0.0
var updateIndex = true
var beginDo = true
var cutsceneTimer = 2.0
var skip = false

func _ready() -> void:
	#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	Global.showCrosshair = false
	Global.gameUI_ChangeFont("res://Fonts/Munson_Roman.otf")
	
	Global.get_node("Misc/Control/Fade").color.a = 1.0
	Global.uiFade = false
	Global.allowToPause = false
	
	$Player.goNumb = true
	$Player.lerpHeadYToCustom = true
	$Player.lookAtLerpHeadY = -1.55
	#$Control/AnimationPlayer.play("intro")
	
	$Wind.play()
	
	SaveData.gameSave.whereAt = 0
	SaveData._saveGame()

func _process(delta: float) -> void:
	if Global.pauseGame:
		$Wind.stream_paused = true
		return
	else:
		$Wind.stream_paused = false
	$Wind.volume_db = lerp($Wind.volume_db, 0.0, 1.0 * delta)

	if beginDo:
		if Input.is_action_just_pressed("deets_skip") and !skip:
			beginIndex = 1
			cutsceneTimer = 0
			nextDuration = 0
			$Control/Text.modulate.a = 1.0
			updateIndex = false
			skip = true
		if updateIndex:
			match beginIndex:
				-1:
					$Control/Text.modulate.a = 0.0
					updateIndex = false
				0:
					nextDuration = 6.0
					updateIndex = false
				1:
					$Control/Text.modulate.a += delta / 2
					$Control/Text.modulate.a = clamp($Control/Text.modulate.a, 0.0, 1.0)
					if $Control/Text.modulate.a >= 1.0:
						updateIndex = false
				2:
					$Control/Text.modulate.a -= delta / 2
					$Control/Text.modulate.a = clamp($Control/Text.modulate.a, 0.0, 1.0)
					$Control/BG.modulate.a = $Control/Text.modulate.a
					$Player.lerpHeadYToCustom = false
					$Player.goNumb = false
					Global.showCrosshair = true
					Global.allowToPause = true
					if $Control/Text.modulate.a <= 0.0:
						updateIndex = false
				3:
					beginDo = false

		if not updateIndex:
			cutsceneTimer -= delta
			if cutsceneTimer <= 0.0:
				cutsceneTimer = nextDuration
				beginIndex += 1
				updateIndex = true

func _on_horse_talk_begin_body_entered(body: Node3D) -> void:
	if body.name.contains("Player"):
		$LevelGeometry/DoorwayFront3.set_deferred("process_mode", Node.PROCESS_MODE_INHERIT)
		$LevelGeometry/DoorwayFront3.show()
		
		$LevelGeometry/DoorwayFront3/Sound.pitch_scale = randf_range(0.8, 1.2)
		$LevelGeometry/DoorwayFront3/Sound.play()
		
		$Horse.begin()
		
		$HorseTalkBegin/CollisionShape3D.set_deferred("disabled", true)
