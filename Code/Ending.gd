extends CanvasLayer

var fade = false

var panels = {
	0: {
		text = "as the player fell down,\nescaping from the hors...",
		panel = preload("res://Sprites/EndingStory/0.png")
	},
	1: {
		text = "they eventually had met\nwith the mystical honse\nonce again.",
		panel = preload("res://Sprites/EndingStory/0.png")
	},
	2: {
		text = "\"wow uh, congratulations\ni honestly thought you wouldn't make it out alive\"",
		panel = preload("res://Sprites/EndingStory/1.png")
	},
	3: {
		text = "\"you failed my riddles like a dumbass, but...\"",
		panel = preload("res://Sprites/EndingStory/1.png")
	},
	4: {
		text = "\"as promised, here is your one dolla.\"",
		panel = preload("res://Sprites/EndingStory/2.png")
	},
	5: {
		text = "the player stares in awe on it's new prize.",
		panel = preload("res://Sprites/EndingStory/2.png")
	},
	6: {
		text = "\"dude. this ain't even a real dollar. you clearly faked that shit.\"",
		panel = preload("res://Sprites/EndingStory/3.png")
	},
	7: {
		text = "\"woops\"",
		panel = preload("res://Sprites/EndingStory/1.png")
	},
	8: {
		text = "that's a real story.\nain't that crazy bro??",
		panel = preload("res://Sprites/EndingStory/4.png")
	},
	9: {
		text = "sir this is a mcdonald's",
		panel = preload("res://Sprites/EndingStory/5.png"),
	}
}

var index = -1
var storyPanel = 0
var updateIndex = true
var nextDuration = 0.0
var skip = false
var cutsceneTimer = 0
var submittedGJ = false
var submittedNG = false
var submit = false

func _ready() -> void:
	$RichTextLabel.visible_ratio = 0
	$Fade.color.a = 2.0
	
	Global.uiFade = false
	Global.get_node("Misc/Control/Fade").color.a = 0.0
	Global.showCrosshair = false
	Global.allowToPause = false
	
	if !Global.customMode:
		if SaveData.gameSave.bestTime == 0:
			SaveData.gameSave.bestTime = Global.finalTime
			submit = true
		elif SaveData.gameSave.bestTime > 0:
			if Global.finalTime < SaveData.gameSave.bestTime:
				SaveData.gameSave.bestTime = Global.finalTime
				submit = true
	else:
		SaveData.gameSave.latestCustomTime = Global.finalTime
	
	SaveData.gameSave.beatGame = true
	SaveData.gameSave.whereAt = 2
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
	
	if SaveData.getSetting("gameplay", "leaderboard") and submit:
		if Global.gamejolt_loggedIn and !submittedGJ:
			Global.gamejolt.scores_add(Global.formatTime(Global.finalTime), Global.finalTime, "", 1001059)
			submittedGJ = true
		if NG.signed_in and !submittedNG:
			submittedNG = true
			NG.scoreboard_submit_time(NewgroundsIds.ScoreboardId.DefaultGame, Global.finalTime)
	
	if Input.is_action_just_pressed("deets_skip") and !skip and index < 18:
		index = 18
		cutsceneTimer = 0
		nextDuration = 2.72
		updateIndex = false
		skip = true
	
	if updateIndex:
		match index:
			-1:
				fade = false
				nextDuration = 4.5
				updateIndex = false
			0:
				updateIndex = false
				nextDuration = 1.0
			1:
				nextDuration = 4.5
				updateIndex = false
			2:
				storyPanel += 1
				$RichTextLabel.visible_ratio = 0
				nextDuration = 1.0
				updateIndex = false
			3:
				fade = true
				nextDuration = 4.5
				updateIndex = false
			4:
				fade = false
				$RichTextLabel.visible_ratio = 0
				storyPanel += 1
				nextDuration = 1.0
				updateIndex = false
			5:
				nextDuration = 4.5
				updateIndex = false
			6:
				storyPanel += 1
				$RichTextLabel.visible_ratio = 0
				nextDuration = 0.5
				updateIndex = false
			7:
				fade = true
				$Music.play(63.8)
				$UnoDolla.play()
				nextDuration = 4.0
				updateIndex = false
			8:
				fade = false
				storyPanel += 1
				$RichTextLabel.visible_ratio = 0
				nextDuration = 1.0
				updateIndex = false
			9:
				nextDuration = 4.5
				updateIndex = false
			10:
				storyPanel += 1
				$RichTextLabel.visible_ratio = 0
				nextDuration = 0.5
				updateIndex = false
			11:
				fade = true
				nextDuration = 4.5
				updateIndex = false
			12:
				fade = false
				$RichTextLabel.visible_ratio = 0
				storyPanel += 1
				nextDuration = 1.0
				updateIndex = false
			13:
				fade = true
				nextDuration = 4.5
				updateIndex = false
			14:
				fade = false
				$RichTextLabel.visible_ratio = 0
				storyPanel += 1
				nextDuration = 1.0
				updateIndex = false
			15:
				fade = true
				nextDuration = 4.5
				updateIndex = false
			16:
				fade = false
				$RichTextLabel.visible_ratio = 0
				storyPanel += 1
				nextDuration = 1.0
				updateIndex = false
			17:
				fade = true
				nextDuration = 2.0
				updateIndex = false
			18:
				fade = false
				$RichTextLabel.visible_ratio = 0
				storyPanel += 1
				nextDuration = 2.72
				updateIndex = false
			19:
				$Music.stop()
				$Undertale.play()
				$Logo.show()
				$StoryPanel.hide()
				$RichTextLabel.hide()
				nextDuration = 5.0
				updateIndex = false
			21:
				if Global.customMode:
					SaveData._unlockAch("customBeat")	
					$RichTextLabel2.text = "[center]Congratulations!\n\nYou've beat Custom Mode\nand earned the mystical\n honse's respect.\n\nLife is not meaningless\nafter all..."
				else:
					$RichTextLabel2.text = "[center]Congratulations!\n\nYou've beat the game\nand have unlocked\nCustom Mode!\n\nPat yourself on\nyour horseback."
					SaveData._unlockAch("beat")
				$RichTextLabel2.show()
				$Logo.hide()
				updateIndex = false
			22:
				get_tree().change_scene_to_file("res://Scenes/Credits.tscn")
	
	cutsceneTimer -= delta
	if cutsceneTimer <= 0.0:
		cutsceneTimer = nextDuration
		index += 1
		updateIndex = true
	
	Global.change_discord_state("won")
