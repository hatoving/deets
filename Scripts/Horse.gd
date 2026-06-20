class_name Horse
extends CharacterBody3D

enum STATE {
	IDLE,
	WANDERING,
	CHASING,
	INVESTIGATING,
	EATING,
	JUMPSCARE,
	DEAD,
}

var currentState = STATE.IDLE
var speed = 3.9
var speedMult = 0.80
var investigateMult = 1.0
var chaseSpeed = 4.5
var accel = 10
var randomTimer = 0
var randomDialogue = [
	preload("res://Audio/Horse/Random_0.mp3"),
	preload("res://Audio/Horse/Random_1.mp3"),
	preload("res://Audio/Horse/Random_2.mp3"),
]
var targetPosition = Vector3()
var waitTimer = 0.0
var currentCam: Camera3D
var heardSomething = false
var hearingTriggered = false
var heardImportant = false
var playerSpotted = false
var playerLost = false
var heardSources = []
var lastPos = Vector3()
var gallopWaitDuration = 0.8
var gallopTimer = 0.1
var shouldPlay = true
var tired = false
var deaf = false
var gonnaEat = false
var angry = false
var wanderTimer = 0.0
var chaseTimer = 0.0
var wanderMax = 20.0
var chaseMax = 15.0
var stuckTimer = 0.0
var deadTimer = 20.0
var munchTimer = -1.0
var yumTimer = -1.0
var dir: Vector3
var origRotCol: Basis
var origRotDeathCol: Basis
var lerpAnim = false
var deadDialogue = [
	preload("res://Audio/Horse/Shot0.ogg"),
	preload("res://Audio/Horse/Shot1.ogg"),
	preload("res://Audio/Horse/Shot2.ogg"),
]
var pedestalDialogue = [
	preload("res://Audio/Horse/ItemDestroy.mp3"),
	preload("res://Audio/Horse/itsnotnice.mp3"),
	preload("res://Audio/Horse/iamnolongerhorsingaround.mp3"),
]


func _ready() -> void:
	origRotCol = $Col.global_transform.basis
	origRotDeathCol = $Death.global_transform.basis

	munchTimer = randf_range(0.0, 0.2)
	yumTimer = randf_range(1.0, 5.0)

	randomTimer = randf_range(25, 45)

	Global.currentGameLoop.rageHorse.connect(_rage)
	Global.currentGameLoop.alertHorseOfSound.connect(_intrigueGotoVec)
	Global.currentGameLoop.raiseSpeedMultHorse.connect(_raise)


func _process(delta: float) -> void:
	if lerpAnim:
		$Sprite.scale.y = lerp($Sprite.scale.y, 1.3, 5.0 * delta)

	if Global.pauseGame or Global.currentGameLoop.pauseCoreGameStuff:
		return

	_updateRay($Ray, 4.0)
	_updateRay($Ray2, 6.5)

	position = position.clamp(Vector3(2.0, 0.0, 2.0), Vector3(Global.currentMazeSize.x - 2, 0.0, Global.currentMazeSize.y - 2))
	chaseSpeed = clamp(chaseSpeed, 4.0, 4.5)

	#print($Agent.get_next_path_position().distance_to(global_position))
	if $Agent.get_next_path_position().distance_to(global_position) < 0.25:
		stuckTimer += delta
		if stuckTimer > 1.0:
			print("mf is stuck")
			var next = $Agent.get_current_navigation_path_index() + 3
			next = clamp(next, 0, $Agent.get_current_navigation_path().size() - 1)
			if next < 0:
				return
			global_position = $Agent.get_current_navigation_path()[next]
			stuckTimer = 0
	else:
		stuckTimer = 0

	$Col.rotation = Vector3.ZERO
	if currentCam == null and Global.currentPlayer != null:
		currentCam = Global.currentPlayer.get_node("Head/Cam")
	else:
		var to_camera = (currentCam.global_transform.origin - global_transform.origin).normalized()
		var forward = -global_transform.basis.z
		var node_rotation = rotation.y
		var angle = atan2(to_camera.x, to_camera.z) - node_rotation

		var angle_degrees = rad_to_deg(angle)
		if angle_degrees < 0:
			angle_degrees += 360

		var frame_index = int((angle_degrees / 360.0) * 8) % 8 if !playerSpotted else 0
		$Sprite.frame = frame_index

	if (dir or speed != 0) and shouldPlay:
		gallopTimer -= delta
		if gallopTimer <= 0:
			$Gallop.pitch_scale = randf_range(0.8, 1.2)
			$Gallop.play()
			if lerpAnim:
				$Sprite.scale.y = 1.1
			gallopTimer = gallopWaitDuration

		if !playerSpotted and !tired and !Global.currentGameLoop.endGame:
			if $Ray.is_colliding():
				var collider = $Ray.get_collider()
				if collider.name.contains("Player"):
					$PedestalDialogue.stop()
					$Random.stop()
					$Spotted.play()
					playerSpotted = true

					waitTimer = 1.5
					currentState = STATE.IDLE

		if (currentState != STATE.CHASING and !Global.currentGameLoop.endGame) and currentState != STATE.DEAD:
			if randomTimer <= 0.0:
				randomTimer = randf_range(25, 45)
				var rand = randi_range(0, randomDialogue.size() - 1)
				$Random.stream = randomDialogue[rand]
				$Random.pitch_scale = randf_range(0.8, 1.2)
				$Random.play()
			else:
				randomTimer -= delta

	match currentState:
		STATE.IDLE:
			if angry:
				speedMult = 1.145
				currentState = STATE.CHASING
			lerpAnim = true
			if !tired:
				speed = 0
			shouldPlay = false
			if !playerSpotted and !tired and !gonnaEat:
				#look_at(heardSources[0].global_position, Vector3.UP, true)
				waitTimer -= delta
				if waitTimer <= 0.0:
					if !heardSomething:
						_pickNewWanderPoint()
						investigateMult = 1.0
						currentState = STATE.WANDERING
					else:
						if heardSources.size() > 0 and heardSources[0]:
							targetPosition = heardSources[0].global_position
							wanderTimer = 0
							currentState = STATE.INVESTIGATING
						else:
							heardSomething = false
			elif playerSpotted and !tired and !gonnaEat:
				var collider = $Ray2.get_collider()
				waitTimer -= delta
				if waitTimer <= 0.0:
					#look_at(Global.currentPlayer.global_position, Vector3.UP, true)
					if ($Ray2.is_colliding() and !collider.name.contains("Player")) or !$Ray2.is_colliding():
						$Spotted.stop()
						$Chase.play()

						chaseMax = randf_range(15, 20)
						speed = chaseSpeed
						investigateMult = 1.0
						currentState = STATE.CHASING
			if tired:
				waitTimer -= delta
				if waitTimer <= 0.0:
					heardSources.clear()
					tired = false
					deaf = false
			if gonnaEat:
				waitTimer -= delta
				if waitTimer <= 0.0:
					investigateMult = 1.0
					currentState = STATE.EATING

			hearingTriggered = false
		STATE.WANDERING:
			if angry:
				speedMult = 1.145
				currentState = STATE.CHASING
			lerpAnim = true
			speed = 3.35 * speedMult
			wanderTimer += delta
			gallopWaitDuration = 0.8
			shouldPlay = true
			if heardSomething:
				targetPosition = global_position
				$Agent.target_position = global_position
				waitTimer = 1
				currentState = STATE.IDLE
				hearingTriggered = false
			else:
				if $Agent.is_navigation_finished() or wanderTimer >= wanderMax:
					#print("finished")
					waitTimer = 3
					wanderTimer = 0
					currentState = STATE.IDLE
					hearingTriggered = false
				else:
					pass
					#look_at(targetPosition, Vector3.UP, true)
		STATE.INVESTIGATING:
			if angry:
				speedMult = 1.145
				currentState = STATE.CHASING
			lerpAnim = true
			if !heardImportant:
				speed = (4.0 * investigateMult) * speedMult
				gallopWaitDuration = 0.5
			if heardImportant:
				speed = (12.0 * investigateMult) * speedMult
				gallopWaitDuration = 0.25
			shouldPlay = true

			if !heardImportant:
				wanderTimer += delta
			else:
				wanderTimer = 0
			if $Agent.is_navigation_finished() or !heardSources[0] or wanderTimer >= wanderMax:
				#print("finished looking at source sound")
				if heardSources[0] is not SoundSensitiveArea3D:
					heardSources[0].queue_free()
				heardSources.remove_at(0)
				if heardImportant:
					$Random.stop()
					if Global.currentGameLoop.pedestalsDestroyed >= Global.currentGameLoop.pedestalAmount:
						$PedestalDialogue.stream = pedestalDialogue[pedestalDialogue.size() - 1]
					else:
						$PedestalDialogue.stream = pedestalDialogue[randi_range(0, pedestalDialogue.size() - 2)]
					$PedestalDialogue.pitch_scale = randf_range(0.8, 1.2)
					$PedestalDialogue.play()
					_pickNewWanderPoint()
					heardImportant = false
					waitTimer = 3
				else:
					waitTimer = 0.5
				currentState = STATE.IDLE
				hearingTriggered = false
			else:
				pass
				#look_at(targetPosition, Vector3.UP, true)
		STATE.CHASING:
			lerpAnim = true
			chaseTimer += delta
			speed = chaseSpeed * speedMult

			$Gallop.volume_db = 1.0
			gallopWaitDuration = 0.4
			shouldPlay = true
			chaseSpeed -= delta / 10

			#look_at(Global.currentPlayer.global_position, Vector3.UP, true)
			var new_target = Global.currentPlayer.global_position
			if $Agent.target_position.distance_to(new_target) > 1.0:
				targetPosition = new_target

			if !Global.currentGameLoop.endGame:
				if chaseTimer >= chaseMax - 4.2 and !tired:
					$Tired.pitch_scale = randf_range(0.5, 1.5)
					$Tired.play()
					tired = true
				if chaseTimer >= chaseMax:
					waitTimer = 5.0
					chaseTimer = 0.0
					speed = 20.0
					chaseMax += randf_range(1.0, 2.0)
					playerSpotted = false
					deaf = true
					targetPosition = _getFarthestMazeTileFromPlayer()
					currentState = STATE.IDLE
			else:
				if angry:
					speedMult = 1.145
					currentState = STATE.CHASING
		STATE.EATING:
			if angry:
				speedMult = 1.145
				currentState = STATE.CHASING
			lerpAnim = false
			waitTimer += delta

			munchTimer -= delta
			yumTimer -= delta
			if munchTimer <= 0.0:
				$Munch.pitch_scale = randf_range(0.8, 1.2)
				$Munch.play()
				munchTimer = randf_range(0.0, 0.2)
			if yumTimer <= 0.0:
				$Yum.pitch_scale = randf_range(0.8, 1.2)
				$Yum.play()
				yumTimer = randf_range(1.0, 2.0)

			$Sprite.scale.y = randf_range(1.2, 1.4)

			var max = 10.0 if !Global.currentGameLoop.endGame else 3.0
			if waitTimer >= max:
				chaseTimer = 0.0
				waitTimer = 1.0
				if Global.currentGameLoop.endGame:
					currentState = STATE.CHASING
				else:
					currentState = STATE.IDLE
				deaf = false
				tired = false
				playerSpotted = false
				gonnaEat = false
				lerpAnim = true
				$Sprite.scale.y = 1.1
		STATE.JUMPSCARE:
			speed = 0
			lerpAnim = false
			shouldPlay = false
			var player = Global.currentPlayer
			var head = player.get_node("Head")
			var from = head.global_transform.origin
			var to = $LookAt.global_position

			var temp_basis = Transform3D().looking_at(to - from, Vector3.UP).basis
			var euler = temp_basis.get_euler()

			Global.allowToPause = false

			#player.shake = true
			player.crouching = false
			player.goNumb = true
			player.lerpHeadYToCustom = true
			player.lookAtLerpHeadY = euler.y
			player.lerpHeadXToCustom = true
			player.lookAtLerpHeadX = euler.x
			player.lerpFOVToCustom = true
			player.targetFOV = 35.0

			$Sprite.scale.x = randf_range(1.0, 1.6)
			$Sprite.scale.y = randf_range(1.2, 1.4)

			Global.currentGameLoop.fogDensityTarget = 5.0
		STATE.DEAD:
			speed = 0
			lerpAnim = false
			shouldPlay = false
			$Col.set_deferred("disabled", true)

			deadTimer -= delta
			if deadTimer <= 0.0:
				chaseTimer = 0.0
				waitTimer = 1.0
				if Global.currentGameLoop.endGame:
					if angry:
						speedMult = 1.145
						currentState = STATE.CHASING
				else:
					currentState = STATE.IDLE
				deaf = false
				tired = false
				lerpAnim = true
				playerSpotted = false
				gonnaEat = false
				$Col.set_deferred("disabled", false)
				$Sprite.show()
				$DeadSprite.hide()

	$Col.global_transform.basis = origRotCol
	$Death.global_transform.basis = origRotDeathCol


func _physics_process(delta: float) -> void:
	if Global.pauseGame or Global.currentGameLoop.pauseCoreGameStuff:
		return

	if currentState != STATE.JUMPSCARE or currentState != STATE.DEAD:
		if $Agent.target_position != targetPosition:
			$Agent.target_position = targetPosition

		dir = $Agent.get_next_path_position() - global_position
		dir = dir.normalized()

		velocity = velocity.lerp((dir * speed) * SaveData.getGameSetting("horse", "speed_multiplier"), accel * delta)
		move_and_slide()


func _pickNewWanderPoint():
	var done = false
	while !done:
		var pos = Vector3(randi_range(0, Global.currentMazeSize.x), 0.0, randi_range(0, Global.currentMazeSize.y))
		if !Global.currentMazeData.has(Vector2(pos.x, pos.z)) or Global.currentMazeData[Vector2(pos.x, pos.z)].type != LevelGen.POINT_TYPE.WALKABLE:
			continue
		else:
			done = true
			var posMid = Global.currentLevelGen.getPointMiddle(Vector2(pos.x, pos.z))
			targetPosition = Vector3(posMid.x, 0.0, posMid.z)
			break

	print("horse TargetPos = " + str(targetPosition))


func _updateRay(ray: RayCast3D, distance: float):
	var ray_origin = ray.global_transform.origin
	var player_pos = Global.currentPlayer.global_transform.origin

	var direction_to_player = (player_pos - ray_origin).normalized()

	var local_direction = ray.global_transform.basis.inverse() * direction_to_player
	local_direction.y = 0.0

	var short_distance = distance
	ray.target_position = local_direction * short_distance


func _getFarthestMazeTileFromPlayer() -> Vector3:
	var farthest_point = global_position
	var max_distance = 0.0

	var player_pos = Global.currentPlayer.global_transform.origin

	for tile_coord in Global.currentMazeData.keys():
		var tile = Global.currentMazeData[tile_coord]

		if tile.type != LevelGen.POINT_TYPE.WALKABLE:
			continue

		var world_pos = Global.currentLevelGen.getPointMiddle(tile_coord)
		var tile_pos = Vector3(world_pos.x, 0.0, world_pos.y)

		var dist = tile_pos.distance_to(player_pos)
		if dist > max_distance:
			max_distance = dist
			farthest_point = tile_pos

	return farthest_point


func _raise(value):
	speedMult += value


func _rage():
	deadTimer = 0.0
	waitTimer = 0.0
	$Mad.pitch_scale = randf_range(0.75, 1.12)
	$Mad.play()
	angry = true


func _die():
	var rand = randi() % 3
	$DeadDialogue.stream = deadDialogue[rand]
	$DeadDialogue.pitch_scale = randf_range(0.8, 1.2)
	$DeadDialogue.play()

	deadTimer = 20.0 if !Global.currentGameLoop.endGame else 10.0
	$DeadSprite.show()
	$Sprite.hide()
	currentState = STATE.DEAD


func _onAudioPlayed(area: SoundSensitiveArea3D):
	if hearingTriggered or playerSpotted or deaf:
		return

	if area in heardSources:
		return

	var overlappingAreas = $SmallSFX.get_overlapping_areas()
	print(overlappingAreas)
	for a in overlappingAreas:
		if a == area:
			#print("HORSE HEARD SOMETHING")
			if Global.currentGameLoop.pedestalsDestroyed > (Global.currentGameLoop.pedestalAmount - 2):
				$IntrigueMad.pitch_scale = randf_range(0.8, 1.2)
				$IntrigueMad.play()
			else:
				$Intrigue.pitch_scale = randf_range(0.8, 1.2)
				$Intrigue.play()

			hearingTriggered = true
			heardSomething = true

			investigateMult += 0.05
			heardSources.append(area)


func _intrigueGotoVec(pos: Vector3):
	if hearingTriggered or playerSpotted or deaf:
		return
	if lastPos == pos:
		return

	heardSources.clear()

	if Global.currentGameLoop.pedestalsDestroyed > (Global.currentGameLoop.pedestalAmount - 2):
		$IntrigueMad.pitch_scale = randf_range(0.8, 1.2)
		$IntrigueMad.play()
	else:
		$Intrigue.pitch_scale = randf_range(0.8, 1.2)
		$Intrigue.play()

	hearingTriggered = true
	heardSomething = true

	var node = Node3D.new()
	get_parent().add_child(node)
	node.global_position = pos
	lastPos = pos

	heardImportant = true
	heardSources.append(node)


func _onSmallSFXEntered(area: Area3D) -> void:
	#print(area.name)
	if area is SoundSensitiveArea3D:
		area.audio_played.connect(_onAudioPlayed)


func _onSmallSFXExited(area: Area3D) -> void:
	if area is SoundSensitiveArea3D:
		area.audio_played.disconnect(_onAudioPlayed)


func _onDeathBody3DEntered(body: Node3D) -> void:
	if gonnaEat or tired or (currentState == STATE.DEAD or currentState == STATE.JUMPSCARE):
		return
	var kill = false
	if body.name.contains("Player"):
		for i in range(2):
			if (Global.currentGameLoop.itemsInInventory[i]).item == "horseFood":
				Global.currentGameLoop._loseItem("horseFood", 1)
				gonnaEat = true

				SaveData._unlockAch("horseFood")

				$HorseFood.pitch_scale = randf_range(0.9, 1.1)
				$HorseFood.play()

				waitTimer = 6.5 if !Global.currentGameLoop.endGame else 5.5
				currentState = STATE.IDLE
				return
			else:
				kill = true
		if kill:
			$Jumpscare.pitch_scale = randf_range(0.95, 1.05)
			$Jumpscare.play()
			if Global.currentGameLoop.isPlayerInShop:
				Global.currentShop._exitShop()
			currentState = STATE.JUMPSCARE


func _on_jumpscare_finished() -> void:
	if currentState == STATE.JUMPSCARE:
		Global.gameUI_reveal = false
		Global.get_node("GameUI/Control").modulate.a = 0.0
		get_tree().change_scene_to_file("res://Scenes/GameOver.tscn")
