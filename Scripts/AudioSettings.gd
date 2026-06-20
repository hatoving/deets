extends Control


func _ready() -> void:
	$Master.value = SaveData.getSetting("audio", "master")
	$Music.value = SaveData.getSetting("audio", "music")
	$SFX.value = SaveData.getSetting("audio", "sfx")
	$Ambience.value = SaveData.getSetting("audio", "ambience")


func _process(_delta: float) -> void:
	$Master/Label.text = "Master (" + str(int((($Master.value + 72.0) / 72.0) * 100)) + "%)"
	$Music/Label.text = "Music (" + str(int((($Music.value + 72.0) / 72.0) * 100)) + "%)"
	$SFX/Label.text = "Sound Effects (" + str(int((($SFX.value + 72.0) / 72.0) * 100)) + "%)"
	$Ambience/Label.text = "Ambience (" + str(int((($Ambience.value + 72.0) / 72.0) * 100)) + "%)"


func _on_master_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, value)
	SaveData.setSetting("audio", "master", value)


func _on_music_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(3, value)
	SaveData.setSetting("audio", "music", value)


func _on_sfx_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(1, value)
	SaveData.setSetting("audio", "sfx", value)


func _on_ambience_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(5, value)
	SaveData.setSetting("audio", "ambience", value)
