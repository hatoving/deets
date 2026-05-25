extends Node

var settings = {
	"video.fullscreen" : true,
	"video.resolution" : 3,
	"video.vsync" : true,
	
	"audio.master" : 0.0,
	"audio.music" : 0.0,
	"audio.sfx" : 0.0,
	"audio.ambience" : 0.0,
	
	"gameplay.cam_sensitivity" : 0.01,
	"gameplay.timer" : false,
	"gameplay.fov" : 90.0,
	"gameplay.leaderboard" : true
}

var gameSettings = {
	"maze.width" : 80,
	"maze.height" : 50,
	"maze.steedium_spawn_ratio" : 0.006,
	"maze.disable_spooky" : false,
	
	"items.valuable_amount" : 4,
	"items.price_multiplier" : 1.0,
	
	"horse.speed_multiplier" : 1.0,
	"horse.spawn_duration" : 20.0,
	"horse.amount" : 1,
	"horse.spawn" : true,
	
	"player.speed_multiplier" : 1.0,
	"player.steedium_collected" : 0,
	"player.steedium_bonus_collected" : 0,
	
	"items.start" : {
		0 : {
			item = "",
			stack = 0,
		},
		1 : {
			item = "",
			stack = 0,
		}
	}
}
var defaultGameSettings = {
	"maze.width" : 80,
	"maze.height" : 50,
	"maze.steedium_spawn_ratio" : 0.006,
	"maze.disable_spooky" : false,
	
	"items.valuable_amount" : 4,
	"items.price_multiplier" : 1.0,
	
	"horse.speed_multiplier" : 1.0,
	"horse.spawn_duration" : 20.0,
	"horse.amount" : 1,
	"horse.spawn" : true,
	
	"player.speed_multiplier" : 1.0,
	"player.steedium_collected" : 0,
	"player.steedium_bonus_collected" : 0,
	
	"items.start" : {
		0 : {
			item = "",
			stack = 0,
		},
		1 : {
			item = "",
			stack = 0,
		}
	}
}

var gameSave = {
	bestTime = 0.0,
	latestCustomTime = 0.0,
	whereAt = 0, # 0 = intro, 1 = minecraft, 2 = game
	doneIntro = false,
	beatGame = false,
	firstTime = true,
}

var achData = {
	"leaving" = false,
	"allHintsWrong" = false,
	"horseFood" = false,
	"gun" = false,
	"gun2" = false,
	"die" = false,
	"beat" = false,
	"customBeat" = false
}

var achDetail = {
	"leaving" : {
		"name" : "Fuck this shit",
		"points" : 5,
		"newgroundsID" : NewgroundsIds.MedalId.FuckThisShit
	},
	"allHintsWrong" : {
		"name" : "Who are you again?",
		"points" : 5,
		"newgroundsID" : NewgroundsIds.MedalId.WhoAreYouAgain
	},
	"horseFood" : {
		"name" : "But HOW hungry can one horse be?",
		"points" : 10,
		"newgroundsID" : NewgroundsIds.MedalId.ButHowHungryCanOneHorseBe
	},
	"gun" : {
		"name" : "Shot dead in the bronx",
		"points" : 15,
		"newgroundsID" : NewgroundsIds.MedalId.ShotDeadInTheBronx
	},
	"gun2" : {
		"name" : "Why even use a hammer when you have this",
		"points" : 10,
		"newgroundsID" : NewgroundsIds.MedalId.WhyEvenUseAHammerWhenYouHaveThis
	},
	"die" : {
		"name" : "Neigh.",
		"points" : 5,
		"newgroundsID" : NewgroundsIds.MedalId.Neigh
	},
	"beat" : {
		"name" : "The prize of a lifetime",
		"points" : 20,
		"newgroundsID" : NewgroundsIds.MedalId.ThePrizeOfALifetime
	},
	"customBeat" : {
		"name" : "This one was super hard, guys",
		"points" : 5,
		"newgroundsID" : NewgroundsIds.MedalId.ThisOneWasSuperHardGuys
	}
}

var defaultAchData = {
	"leaving" = false,
	"allHintsWrong" = false,
	"horseFood" = false,
	"gun" = false,
	"gun2" = false,
	"die" = false,
	"beat" = false,
	"customBeat" = false
}

var defaultGameSave = {
	bestTime = 0.0,
	latestCustomTime = 0.0,
	whereAt = 0, # 0 = intro, 1 = minecraft, 2 = game
	doneIntro = false,
	beatGame = false,
	firstTime = true,
}

var availableScreenSizes = []

func _ready() -> void:
	availableScreenSizes.append(Vector2i(320, 240))
	availableScreenSizes.append(Vector2i(640, 480))
	availableScreenSizes.append(Vector2i(1280, 960))
	availableScreenSizes.append(Vector2i(1280, 720))
	availableScreenSizes.append(DisplayServer.screen_get_size())
	setSetting("video","resolution", availableScreenSizes.size() - 1)
	
	_loadSettings()
	
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if getSetting("video", "fullscreen") else DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(availableScreenSizes[getSetting("video", "resolution")])
	var screen_size = DisplayServer.screen_get_size()
	var window_size = DisplayServer.window_get_size()
	var new_position = (screen_size - window_size) / 2
	DisplayServer.window_set_position(new_position)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if getSetting("video", "vsync") else DisplayServer.VSYNC_DISABLED)
	
	AudioServer.set_bus_volume_db(0, getSetting("audio", "master"))#
	AudioServer.set_bus_volume_db(1, getSetting("audio", "sfx"))
	AudioServer.set_bus_volume_db(3, getSetting("audio", "music"))
	AudioServer.set_bus_volume_db(5, getSetting("audio", "ambience"))
	
	_saveSettings()
	
	gameSave.whereAt = 0
	_loadGame()
	gameSettings = defaultGameSettings
	
	_loadAch()
	
func _unlockAch(key):
	for i in achData:
		if i == key and !achData[i]:
			if i != "customBeat" and Global.customMode:
				return
			var loggedin = false
			if NG.signed_in:
				loggedin = true
				NG.medal_unlock(achDetail[i].newgroundsID)
			if loggedin:
				achData[i] = true
				Global.get_node("Misc/Achievement/XboxAch/Label").text = "Achievement unlocked!\n" + str(achDetail[i].points) + "G - " + achDetail[i].name
				Global.get_node("Misc/Achievement/XboxAch/Anim").play("ach")
	_saveAch()

func getSetting(area, key):
	return settings[area + "." + key]
	
func setSetting(area, key, value):
	settings[area + "." + key] = value

func getGameSetting(area, key):
	return gameSettings[area + "." + key]
	
func setGameSetting(area, key, value):
	gameSettings[area + "." + key] = value
	
func _saveSettings():
	print("Saving settings!")
	var file = FileAccess.open("user://settings.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(settings))
		file.close()

func _saveGame():
	print("Saving encrypted game!")
	var file := FileAccess.open_encrypted_with_pass("user://gameSave.dat", FileAccess.WRITE, "Bitches&Horses&Lmao!!@l")
	if file:
		var json_string = JSON.stringify(gameSave)
		file.store_string(json_string)
		file.close()
	else:
		print("Failed to open file for saving.")

func _loadGame():
	print("Loading encrypted game!")
	if not FileAccess.file_exists("user://gameSave.dat"):
		gameSave = defaultGameSave.duplicate(true)
		print("Save file not found.")
		return
	
	var file := FileAccess.open_encrypted_with_pass("user://gameSave.dat", FileAccess.READ, "Bitches&Horses&Lmao!!@l")
	if file:
		var content := file.get_as_text()
		file.close()

		var result = JSON.parse_string(content)
		if result is Dictionary:
			print(result)
			gameSave = result
			print("Loaded save data.")
		else:
			gameSave = defaultGameSave.duplicate(true)
			print("Failed to parse save data.")
	else:
		gameSave = defaultGameSave.duplicate(true)
		print("Failed to open save file for loading.")
		
func _saveAch():
	print("Saving encrypted ach!")
	var file := FileAccess.open_encrypted_with_pass("user://achData.dat", FileAccess.WRITE, "BitchesACH!!!&Hor!!eACHs&Lmao!!@l")
	if file:
		var json_string = JSON.stringify(achData)
		file.store_string(json_string)
		file.close()
	else:
		print("Failed to open file for saving.")

func _loadAch():
	print("Loading encrypted ach!")
	if not FileAccess.file_exists("user://achData.dat"):
		achData = defaultAchData.duplicate(true)
		print("ach file not found.")
		return
	
	var file := FileAccess.open_encrypted_with_pass("user://achData.dat", FileAccess.READ, "BitchesACH!!!&Hor!!eACHs&Lmao!!@l")
	if file:
		var content := file.get_as_text()
		file.close()

		var result = JSON.parse_string(content)
		if result is Dictionary:
			print(result)
			achData = result
			print("Loaded ach data.")
		else:
			achData = defaultAchData.duplicate(true)
			print("Failed to parse ach data.")
	else:
		achData = defaultAchData.duplicate(true)
		print("Failed to open ach file for loading.")
			

func _loadSettings():
	print("Loading settings!")
	if not FileAccess.file_exists("user://settings.json"):
		return
	
	var file = FileAccess.open("user://settings.json", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()

		var result = JSON.parse_string(content)
		if result is Dictionary:
			print(result)
			settings = result.duplicate(true)
			
func _exit_tree() -> void:
	_saveGame()
	_saveSettings()
