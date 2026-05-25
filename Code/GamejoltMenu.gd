extends CanvasLayer

func _ready() -> void:
	if Global.gamejolt_loggedIn:
		$Log.disabled = true
		$Label3.text = "[color=green]Successfully logged in!"
	Global.gamejolt.gamejolt_request_completed.connect(_onReqCompleted)
	
func _onReqCompleted(type: String, message: Dictionary):
	print("[gamejotl login] " + type + " ..... " + str(message))
	if type == "/users/auth/" and !message.success:
		$Label3.text = message.message
	elif type == "/users/auth/" and message.success:
		$Label3.text = "[color=green]Successfully logged in!"
		Global.gamejolt_loggedIn = true
		$Log.disabled = true
	elif type == "/trophies/remove-achieved/" and message.success:
		$Label3.text = "Sucessfully reset trophies!"
		#
	$Close.disabled = false

func _on_log_pressed() -> void:
	$Close.disabled = true
	Global.gamejolt.user_auth($Username.text, $GameToken.text)

func _on_close_pressed() -> void:
	self.visible = false
	
func deleteFile(fileName: String):
	var filePath = "user://" + fileName
	if FileAccess.file_exists(filePath):
		var dir = DirAccess.open("user://")
		if dir:
			var error = dir.remove(fileName)
			if error == OK:
				print("Deleted:", fileName)
			else:
				print("Failed to delete:", fileName, "Error code:", error)
		else:
			print("Failed to open user directory")
	else:
		print("File does not exist:", fileName)

func _on_reset_pressed() -> void:
	if Global.gamejolt_loggedIn:
		for i in SaveData.achDetail:
			Global.gamejolt.trophy_remove_achieved(int(SaveData.achDetail[i].gamejoltID))
		deleteFile("achData.dat")
		$Close.disabled = true
