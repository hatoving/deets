extends InteractableStaticBody3D

var doCutscene = false
var done = false

var index = -1
var didIndex = false
var nextIndexDuration = 0.0

var cutsceneTimer = 0.0

var explosionScene = preload("res://Scenes/LevelGen/Explosion.tscn")
var explosionTimer = 0.0

func _ready() -> void:
	onInteract.connect(_onInteract)

func _onInteract():
	if int(Global.currentGameLoop.valuableHorseItemAmount - Global.currentGameLoop.valuableHorseItemsDestroyed) <= 0 and int(Global.currentGameLoop.steediumNeededToEscape - Global.currentGameLoop.steediumCollected) <= 0:
		Global.currentGameLoop.pauseCoreGameStuff = true
		Global.currentGameLoop.get_node("Ambience").stop()
		Global.currentGameLoop.get_node("AmbienceSpooky").stop()
		doCutscene = true
		isInteractable = false
	
func _process(delta: float) -> void:
	if !doCutscene:
		if int(Global.currentGameLoop.steediumNeededToEscape - Global.currentGameLoop.steediumCollected) <= 0:
			$Mesh/Label1.text = "Done!"
		else:
			$Mesh/Label1.text = "x" + str(int(Global.currentGameLoop.steediumNeededToEscape - Global.currentGameLoop.steediumCollected))
		
		if int(SaveData.getGameSetting("items", "valuable_amount") - Global.currentGameLoop.valuableHorseItemsDestroyed) <= 0 and int(Global.currentGameLoop.steediumNeededToEscape - Global.currentGameLoop.steediumCollected) <= 0:
			$Mesh/Label2.text = "Congratulations.\nNow interact with\nme and get your\nprize."
		elif int(SaveData.getGameSetting("items", "valuable_amount") - Global.currentGameLoop.valuableHorseItemsDestroyed) <= 0 and int(Global.currentGameLoop.steediumNeededToEscape - Global.currentGameLoop.steediumCollected) > 0:
			$Mesh/Label2.text = "You have destroyed\nthe items, but\n you still need steedium."
		else:
			$Mesh/Label2.text = "There are still " + str(int(Global.currentGameLoop.valuableHorseItemAmount - Global.currentGameLoop.valuableHorseItemsDestroyed)) + "\nValuable Horse Items.\nDestroy them all\nto proceed."
		
		
	if int(Global.currentGameLoop.valuableHorseItemAmount - Global.currentGameLoop.valuableHorseItemsDestroyed) <= 0 and int(Global.currentGameLoop.steediumNeededToEscape - Global.currentGameLoop.steediumCollected) <= 0:
		hint = "press [color=yellow]Left Mouse Button[color=yellow] to proceed"
		
		if Global.pauseGame:
			return
		
		if doCutscene:
			if !didIndex:
				match index:
					-1:
						nextIndexDuration = 3.0
					0:
						$Timer.pitch_scale = randf_range(0.95, 1.05)
						$Timer.play()
						$Mesh/Label1.text = "10"
						didIndex = true
						nextIndexDuration = 2.0
					1:
						$Timer.pitch_scale = randf_range(0.95, 1.05)
						$Timer.play()
						$Mesh/Label1.text = "9"
						didIndex = true
						nextIndexDuration = 1.0
					2:
						$Timer.pitch_scale = randf_range(0.95, 1.05)
						$Timer.play()
						$Mesh/Label1.text = "8"
						didIndex = true
						nextIndexDuration = 0.5
					3:
						$Timer.pitch_scale = randf_range(0.95, 1.05)
						$Timer.play()
						$Mesh/Label1.text = "7"
						didIndex = true
						nextIndexDuration = 0.25
					4:
						$Timer.pitch_scale = randf_range(0.95, 1.05)
						$Timer.play()
						$Mesh/Label1.text = "6"
						didIndex = true
						nextIndexDuration = 0.125
					5:
						$Timer.pitch_scale = randf_range(0.95, 1.05)
						$Timer.play()
						$Mesh/Label1.text = "5"
						didIndex = true
						nextIndexDuration = 0.125 / 2
					6:
						$Timer.pitch_scale = randf_range(0.95, 1.05)
						$Timer.play()
						$Mesh/Label1.text = "4"
						didIndex = true
						nextIndexDuration = 0.125 / 4
					7:
						$Timer.pitch_scale = randf_range(0.95, 1.05)
						$Timer.play()
						$Mesh/Label1.text = "3"
						didIndex = true
						nextIndexDuration = 0.125 / 6
					8:
						$Timer.pitch_scale = randf_range(0.95, 1.05)
						$Timer.play()
						$Mesh/Label1.text = "2"
						didIndex = true
						nextIndexDuration = 0.125 / 8
					9:
						$Timer.pitch_scale = randf_range(0.95, 1.05)
						$Timer.play()
						$Mesh/Label1.text = "1"
						didIndex = true
						nextIndexDuration = 0.125 / 10
					10:
						$Timer.pitch_scale = randf_range(0.95, 1.05)
						$Timer.play()
						$Mesh/Label1.text = "0"
						didIndex = true
						nextIndexDuration = 10.0
					11:
						$Mesh/Label1.text = "DEAD"
						$Mesh/Label2.text = "You're done for."
						explosionTimer -= delta
						if explosionTimer <= 0.0:
							var explo = explosionScene.instantiate()
							explo.position = Vector3(randf_range(0.0, 1.0), randf_range(0.0, 1.0), randf_range(0.0, 1.0))
							add_child(explo)
							explosionTimer = randf_range(0.1, 0.35)
						$Mesh.position.x = randf_range(0.3, 0.7)
						$Mesh.position.z = randf_range(0.3, 0.7)
						$Mesh.position.y -= delta / 6
						nextIndexDuration = 2.0
					12:
						pass
					13:
						Global.currentGameLoop.endGame = true
						Global.currentGameLoop._loseSteedium(Global.currentGameLoop.steediumNeededToEscape)
						Global.gameUI_RevealEvent("[color=red]Run[/color].", 3.0)
						Global.currentGameLoop.pauseCoreGameStuff = false
						Global.currentGameLoop.rageHorse.emit()
						Global.currentGameLoop._playFinal()
						Global.currentStartFence.toggleClose()
						didIndex = true
						doCutscene = false
			
			cutsceneTimer -= delta
			if cutsceneTimer <= 0.0:
				cutsceneTimer = nextIndexDuration
				didIndex = false
				index += 1
	else:
		hint = "I don't have enough to proceed."
	
	var currentWidth = overlayMat.get_shader_parameter("outline_width")
	overlayMat.set_shader_parameter("outline_width", lerp(currentWidth, targetOutlineWidth, 0.3))
