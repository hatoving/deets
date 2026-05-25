extends InteractableStaticBody3D
class_name ValuableHorseItem

var time = 0
var y_offset = 0.0
var orig_y = 12.0

@export var destroy = false
var done = false

var screamTimer = 0.0

var explosionScene = preload("res://LevelGen/Explosion.tscn")
var explosionTimer = 0.0

func _ready() -> void:
	onInteract.connect(_onInteract)
	screamTimer = randf_range(15, 40)

func _changeHorseItem(index):
	match index:
		0:
			$Sprite.texture = load("res://Sprites/HorseShoe.png")
		1:
			$Sprite.texture = load("res://Sprites/HorseWhistle.png")
		2:
			$Sprite.texture = load("res://Sprites/HorseSaddle.png")
		3:
			$Sprite.texture = load("res://Sprites/HorseLead.png")
			
func _onInteract():
	if Global.currentGameLoop:
		if (Global.currentGameLoop.itemsInInventory[Global.currentGameLoop.currentlySelectedItem]).item == "hammer":
			Global.currentGameLoop._loseItem("hammer", 1)
			destroy = true
			isInteractable = false

func triggerDestroy():
	destroy = true
	isInteractable = false

func _process(delta: float) -> void:
	if (Global.currentGameLoop.itemsInInventory[Global.currentGameLoop.currentlySelectedItem]).item == "hammer":
		hint = "press [color=yellow]Left Mouse Button[/color] to smash"
	else:
		hint = "I need something [color=yellow]hard[/color] to smash this..."
		
	if !done:
		screamTimer -= delta
		if screamTimer <= 0.0:
			$Scream.pitch_scale = randf_range(0.9, 1.1)
			$Scream.play()
			screamTimer = randf_range(15, 40)
	
	if !destroy and !done:
		time += delta
		y_offset = cos(time)
		$Sprite.position.y = (orig_y + y_offset) / 8
	
		var currentWidth = overlayMat.get_shader_parameter("outline_width")
		overlayMat.set_shader_parameter("outline_width", lerp(currentWidth, targetOutlineWidth, 0.3))
	elif destroy and !done:
		$Sprite.visible = false
		$Mesh.position.x = randf_range(0.3, 0.7)
		$Mesh.position.z = randf_range(0.3, 0.7)
		$Mesh.position.y -= delta / 6
		
		if Global.pauseGame:
			return
		
		explosionTimer -= delta
		if explosionTimer <= 0.0:
			var explo = explosionScene.instantiate()
			explo.position = Vector3(randf_range(0.0, 1.0), randf_range(0.0, 1.0), randf_range(0.0, 1.0))
			add_child(explo)
			explosionTimer = randf_range(0.1, 0.35)
		if $Mesh.position.y < -1.0:
			if Global.currentLevelGen != null:
				Global.currentGameLoop.diamondBonusAmount += (int(Global.currentGameLoop.diamondsNeededToEscape / 4)) * Global.currentGameLoop.valuableHorseItemDiamondMult
				Global.currentGameLoop.valuableHorseItemDiamondMult += 0.5
				Global.currentGameLoop.valuableHorseItemsDestroyed += 1
				Global.currentGameLoop.raiseSpeedMultHorse.emit(0.05)
				destroy = false
				done = true
				if Global.currentGameLoop.valuableHorseItemsDestroyed != Global.currentGameLoop.valuableHorseItemAmount:
					Global.gameUI_RevealEvent("Only [shake][color=maroon]" + (str(Global.currentGameLoop.valuableHorseItemAmount - Global.currentGameLoop.valuableHorseItemsDestroyed)) + "[/color][/shake] to go.")
				if Global.currentGameLoop.valuableHorseItemsDestroyed == Global.currentGameLoop.valuableHorseItemAmount:
					Global.gameUI_RevealEvent("Get to the very edge of the map. Make sure you have enough diamonds... and then escape.", 8.0)
				$Audio.stop()
				$Col.set_deferred("disabled", true)
				$Mesh.visible = false
				$Grave.visible = true
