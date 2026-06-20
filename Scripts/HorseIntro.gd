extends Sprite3D

@export var theEntireFuckingFloor: Node3D
@export var player: CharacterBody3D
@export var orig_y = 0

var time = 0
var y_offset = 0
var dialogue = [
	preload("res://Audio/HorseIntro/00.ogg"),
	preload("res://Audio/HorseIntro/1.ogg"),
	preload("res://Audio/HorseIntro/1a.ogg"),
	preload("res://Audio/HorseIntro/2.ogg"),
	preload("res://Audio/HorseIntro/2a.ogg"),
	preload("res://Audio/HorseIntro/3.ogg"),
	preload("res://Audio/HorseIntro/4.ogg"),
]
var index = -1
var indexDuration = 0.0
var cutsceneTimer = 0.0
var indexUpdate = true
var doCutscene = false
var pauseCutscene = false
var whichOneRight = 0
var gotItRight = false
var questionIndex = 0
var wrong = 0


func _process(delta: float) -> void:
	if Global.pauseGame:
		$Dialogue.stream_paused = true
		return
	else:
		$Dialogue.stream_paused = false

	time += delta
	y_offset = cos(time)
	position.y = (orig_y + y_offset) / 8

	if doCutscene and !pauseCutscene:
		if indexUpdate:
			match index:
				-1:
					indexDuration = 12.0
					indexUpdate = false
				0:
					$Dialogue.stream = dialogue[0]
					$Dialogue.play()
					indexUpdate = false
					indexDuration = 5.5
				1:
					$Dialogue.stream = dialogue[1]
					$Dialogue.play()
					indexUpdate = false
					indexDuration = 0.0
				2:
					whichOneRight = 1
					setAnswers(["13", "14", "5"])
					enableAnswers()
					pauseCutscene = true
				3:
					match questionIndex:
						1:
							if gotItRight:
								index = 4
								cutsceneTimer = 2.0
								indexDuration = 2.0
							else:
								indexDuration = 7.5
						2:
							if gotItRight:
								index = 7
								cutsceneTimer = 0.0
								indexDuration = 5.0
							else:
								index = 6
								cutsceneTimer = 0.0
								indexDuration = 5.0
						3:
							index = 9
							cutsceneTimer = 0.0
							indexDuration = 10.0
					indexUpdate = false
				4:
					$Dialogue.stream = dialogue[2]
					$Dialogue.play()
					indexUpdate = false
					indexDuration = 0.0
				5:
					$Dialogue.stream = dialogue[3]
					$Dialogue.play()
					indexUpdate = false
					indexDuration = 5.5
				6:
					whichOneRight = 0
					setAnswers(["horse", "donkey", "magical\nunicorn"])
					enableAnswers()
					pauseCutscene = true
				7:
					$Dialogue.stream = dialogue[4]
					$Dialogue.play()
					indexUpdate = false
					indexDuration = 5.0
				8:
					$Dialogue.stream = dialogue[5]
					$Dialogue.play()
					indexUpdate = false
					indexDuration = 0.0
				9:
					whichOneRight = -1
					setAnswers(["women's rights", "the right to\nhorse around", "TBA"])
					enableAnswers()
					pauseCutscene = true
				10:
					$Dialogue.stream = dialogue[6]
					$Dialogue.play()
					indexUpdate = false
					indexDuration = 6.18
				11:
					Global.allowToPause = false

					$Floor.play()
					$Cymbal.play()

					player.get_node("Falling").play()
					theEntireFuckingFloor.queue_free()

					Global.get_node("Misc/Control/Fade").color.a = 0.0
					Global.uiFade = true

					indexDuration = 0.0
					indexUpdate = false
				12:
					get_tree().change_scene_to_file("res://Scenes/Level.tscn")
					pass

		cutsceneTimer -= delta
		if cutsceneTimer <= 0.0:
			index += 1
			indexUpdate = true
			cutsceneTimer = indexDuration


func begin():
	doCutscene = true


func enableAnswers():
	get_parent().get_node("Answers").set_deferred("process_mode", PROCESS_MODE_INHERIT)
	get_parent().get_node("Answers").show()


func disableAnswers():
	get_parent().get_node("Answers").set_deferred("process_mode", PROCESS_MODE_DISABLED)
	get_parent().get_node("Answers").hide()


func setAnswers(answers: PackedStringArray):
	for i in range(3):
		get_parent().get_node("Answers/Answer" + str(i + 1) + "/Mesh/Label2").text = answers[i]


func moveOn(num):
	if num != whichOneRight:
		gotItRight = false
		$Wrong.play()
		wrong += 1
	else:
		gotItRight = true
		$Correct.play()
	questionIndex += 1
	print(questionIndex)
	index = 3
	pauseCutscene = false
	disableAnswers()
	if wrong >= 3:
		SaveData._unlockAch("allHintsWrong")


func _on_answer_1_on_interact() -> void:
	moveOn(0)


func _on_answer_2_on_interact() -> void:
	moveOn(1)


func _on_answer_3_on_interact() -> void:
	moveOn(2)
