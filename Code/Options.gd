extends CanvasLayer

var index = 0

@export var mainMenu : CanvasLayer
@export var clickSFX : AudioStreamPlayer

signal onExit

func switchMenus():
	match index:
		0:
			$Label.text = "Video"
			$Video.visible = true
			$Audio.visible = false
			$Game.visible = false
		1:
			$Label.text = "Audio"
			$Video.visible = false
			$Audio.visible = true
			$Game.visible = false
		2:
			$Label.text = "Gameplay"
			$Video.visible = false
			$Audio.visible = false
			$Game.visible = true
			
func _ready() -> void:
	switchMenus()

func _on_back_pressed() -> void:
	onExit.emit()
	clickSFX.play()
	mainMenu.visible = true
	self.visible = false
	SaveData._saveSettings()

func _on_left_pressed() -> void:
	clickSFX.play()
	index -= 1
	index = clamp(index, 0, 2)
	switchMenus()

func _on_right_pressed() -> void:
	clickSFX.play()
	index += 1
	index = clamp(index, 0, 2)
	switchMenus()
