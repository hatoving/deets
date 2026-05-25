extends Control

var fade = false

var panels = {
	0: {
		text = "\"fuck you,\" the player\nproudly proclaimed as\nthey exit the building.",
		panel = preload("res://Sprites/Ending2Story/0.png")
	},
	1: {
		text = "\"this is a huge waste\nof my god damn time\"",
		panel = preload("res://Sprites/Ending2Story/0.png")
	},
}

var index = -1
var storyPanel = 0
var updateIndex = true
var nextDuration = 0.0
var skip = false
var cutsceneTimer = 0

func _ready() -> void:
	$RichTextLabel.visible_ratio = 0
	$Fade.color.a = 2.0
	
	Global.uiFade = false
	Global.get_node("Misc/Control/Fade").color.a = 0.0
	Global.showCrosshair = false
	Global.allowToPause = false
	
	if Global.finalTime < SaveData.gameSave.bestTime:
		SaveData.gameSave.bestTime = Global.finalTime

	SaveData._saveGame()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	
func _process(delta: float) -> void:
	if fade:
		$Fade.color.a += delta * 4
	else:
		$Fade.color.a -= delta * 4
	$Fade.color.a = clamp($Fade.color.a, 0.0, 1.0)
	
	$StoryPanel.texture = panels[storyPanel].panel
	$RichTextLabel.text = panels[storyPanel].text
	
	$RichTextLabel.visible_ratio += delta
	
	if Input.is_action_just_pressed("deets_skip") and !skip and index < 2:
		index = 1
		cutsceneTimer = 0
		nextDuration = 2.72
		skip = true
	
	if updateIndex:
		match index:
			-1:
				fade = false
				nextDuration = 4.5
				updateIndex = false
			0:
				nextDuration = 2.2
				updateIndex = false
			1:
				fade = false
				$RichTextLabel.visible_ratio = 0
				storyPanel += 1
				nextDuration = 2.72
				updateIndex = false
			2:
				$Music.stop()
				$Undertale.play()
				$Logo.show()
				$StoryPanel.hide()
				$RichTextLabel.hide()
				nextDuration = 3.0
				updateIndex = false
			3:
				$Logo.hide()
				SaveData._unlockAch("leaving")
				updateIndex = false
			4:
				get_tree().change_scene_to_file("res://Scenes/GameOver.tscn")
	
	cutsceneTimer -= delta
	if cutsceneTimer <= 0.0:
		cutsceneTimer = nextDuration
		index += 1
		updateIndex = true
