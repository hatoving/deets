extends Control


func _ready() -> void:
	$Resolution.text = "Resolution Size : " + str(SaveData.availableScreenSizes[SaveData.getSetting("video", "resolution")].x) + "x" + str(SaveData.availableScreenSizes[SaveData.getSetting("video", "resolution")].y)


func _process(_delta: float) -> void:
	$Fullscreen.text = "Fullscreen : " + ("On" if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN else "Off")
	$Resolution.text = "Resolution Size : " + str(SaveData.availableScreenSizes[SaveData.getSetting("video", "resolution")].x) + "x" + str(SaveData.availableScreenSizes[SaveData.getSetting("video", "resolution")].y)
	$"V-Sync".text = "V-Sync : " + ("On" if DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_ENABLED else "Off")

	if Global.os == "Web":
		$Resolution.visible = false
		$"V-Sync".visible = false
		$Resolution.disabled = true
		$"V-Sync".disabled = true


func _on_fullscreen_pressed() -> void:
	get_parent().clickSFX.play()
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		SaveData.setSetting("video", "fullscreen", false)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		SaveData.setSetting("video", "fullscreen", true)


func _on_resolution_pressed() -> void:
	get_parent().clickSFX.play()
	if SaveData.getSetting("video", "resolution") + 1 > SaveData.availableScreenSizes.size() - 1:
		SaveData.setSetting("video", "resolution", 0)
	else:
		SaveData.setSetting("video", "resolution", SaveData.getSetting("video", "resolution") + 1)

	DisplayServer.window_set_size(SaveData.availableScreenSizes[SaveData.getSetting("video", "resolution")])

	var screen_size = DisplayServer.screen_get_size()
	var window_size = DisplayServer.window_get_size()
	var new_position = (screen_size - window_size) / 2
	DisplayServer.window_set_position(new_position)


func _on_v_sync_pressed() -> void:
	get_parent().clickSFX.play()
	if DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_ENABLED:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		SaveData.setSetting("video", "vsync", false)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		SaveData.setSetting("video", "vsync", true)
