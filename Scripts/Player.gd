class_name Player
extends CharacterBody3D

const SPEED = 4.3
const CROUCH_SPEEED = 1.2
const ACCELERATION = 10.0
const FRICTION = 3.0
const JUMP_VELOCITY = 4.5

@export var goNumb = false
@export var startingRotation: Vector2
@export var jumpAtStart = true

var lerpCameraPosToCustom = false
var lerpHeadXToCustom = false
var lerpHeadYToCustom = false
var lerpPosToCustom = false
var lerpFOVToCustom = false
var lerpCameraCustomPos = Vector3()
var lookAtLerpHeadY: float = 0.0
var lookAtLerpHeadX: float = 0.0
var lerpPosCustom = Vector3()
var lookSensitviity := 0.01
var lookSmoothness := 20.0
var targetRotY := 0.0
var targetRotX := 0.0
var targetFOV = 90.0
var currentSpeed = SPEED
var crouching = false
var peeking = false
var interactingWithSomethingElse = false
var hidingUI = false
var shake = false
var shakeOrigPos = Vector3.ONE
var direction: Vector3 = Vector3.ZERO
var footstepWaitDuration = 0.35
var footstepTimer = 0.1
var has_moved = false
var lastRayBody: InteractableStaticBody3D
var currentRayBody: InteractableStaticBody3D
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready() -> void:
	targetRotX = $Head.rotation.y
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	targetRotX = startingRotation.x
	targetRotY = startingRotation.y

	if jumpAtStart:
		velocity.y = 14
		$Appear.pitch_scale = randf_range(0.9, 1.1)
		$Appear.play()

	Global.currentPlayer = self


func _process(delta: float) -> void:
	if lerpCameraPosToCustom:
		%Cam.global_position = lerp(%Cam.global_position, lerpCameraCustomPos, 5.0 * delta)
	else:
		if !crouching:
			%Cam.position = lerp(%Cam.position, Vector3.ZERO, 5.0 * delta)
		else:
			%Cam.position = lerp(%Cam.position, Vector3(0.0, -.75, 0.0), 14.0 * delta)

	lookSensitviity = SaveData.getSetting("gameplay", "cam_sensitivity")

	if !lerpHeadYToCustom:
		$Head.rotation.y = lerp_angle($Head.rotation.y, targetRotY, lookSmoothness * delta)
		%Cam.rotation.x = lerp_angle(%Cam.rotation.x, targetRotX, lookSmoothness * delta)

	if lerpFOVToCustom:
		%Cam.fov = lerp($%Cam.fov, targetFOV, 0.1 * delta)
	else:
		%Cam.fov = SaveData.getSetting("gameplay", "fov")

	if Global.pauseGame or (Global.currentGameLoop and Global.currentGameLoop.pauseCoreGameStuff and Global.currentGameLoop.start):
		return

	if !goNumb:
		%Ray.enabled = true
		if %Ray.is_colliding():
			var collider = %Ray.get_collider()
			if collider is InteractableStaticBody3D:
				currentRayBody = collider
			if collider.get_parent() is InteractableStaticBody3D:
				currentRayBody = collider.get_parent()
		else:
			lastRayBody = currentRayBody
			if lastRayBody:
				interactingWithSomethingElse = false
				lastRayBody.setHighlight(false)
			currentRayBody = null

		if currentRayBody != null and currentRayBody.isInteractable:
			print(currentRayBody.name)
			currentRayBody.setHighlight(true)
			interactingWithSomethingElse = true
			if Input.is_action_just_pressed("deets_interact"):
				interactingWithSomethingElse = false
				currentRayBody.setHighlight(false)
				currentRayBody.onInteract.emit()

		crouching = Input.is_action_pressed("deets_crouch") and is_on_floor()

		if crouching:
			currentSpeed = CROUCH_SPEEED
			footstepWaitDuration = 1.5
		else:
			currentSpeed = SPEED
			footstepWaitDuration = 0.35

		if Input.is_action_just_released("deets_crouch"):
			footstepTimer = 0.0

		if Input.is_action_just_pressed("deets_peek"):
			if not peeking:
				peeking = true
				targetRotY += deg_to_rad(180)
				$Head.rotation.y = targetRotY

		if Input.is_action_just_released("deets_peek"):
			if peeking:
				peeking = false
				targetRotY -= deg_to_rad(180)
				$Head.rotation.y = targetRotY

		if direction and is_on_floor():
			has_moved = true
			footstepTimer -= delta
			if footstepTimer <= 0:
				if crouching:
					var rand = randi() % 4
					if rand == 3:
						$Footstep.pitch_scale = randf_range(0.8, 1.2)
						$Footstep.play()
						$Footstep/AreaFS.monitorable = true
						$Footstep/AreaFS.audio_played.emit($Footstep/AreaFS)
				else:
					$Footstep.pitch_scale = randf_range(0.8, 1.2)
					$Footstep.play()
					$Footstep/AreaFS.monitorable = true
					$Footstep/AreaFS.audio_played.emit($Footstep/AreaFS)
				footstepTimer = footstepWaitDuration
		else:
			$Footstep/AreaFS.monitorable = false
	else:
		Global.gameUI_DisableHint()
		if shake:
			if shakeOrigPos == Vector3.ONE:
				shakeOrigPos = %Cam.global_position

			%Cam.global_position = Vector3(shakeOrigPos.x + randf_range(-0.05, 0.05), 0.0, shakeOrigPos.y + randf_range(-0.05, 0.05))

		%Ray.enabled = false

	if hidingUI:
		Global.gameUI.hide()
		Global.shopUI.hide()
		Global.miscUI.hide()
	else:
		Global.gameUI.show()
		if Global.inShopUI:
			Global.shopUI.show()
		else:
			Global.shopUI.hide()
		Global.miscUI.show()


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	if lerpHeadXToCustom:
		%Cam.rotation.x = lerp_angle(%Cam.rotation.x, lookAtLerpHeadX, 5.0 * delta)
	if lerpHeadYToCustom:
		if !lerpHeadXToCustom:
			%Cam.rotation.x = lerp_angle(%Cam.rotation.x, deg_to_rad(0), 5.0 * delta)
		$Head.rotation.y = lerp_angle($Head.rotation.y, lookAtLerpHeadY, 5.0 * delta)
		$Head.rotation.z = lerp($Head.rotation.z, 0.0, 5 * delta)
	if lerpPosToCustom:
		global_position = global_position.lerp(lerpPosCustom, 5.0 * delta)

	if Global.pauseGame or (Global.currentGameLoop and Global.currentGameLoop.pauseCoreGameStuff and Global.currentGameLoop.start):
		return

	if !goNumb:
		if not is_on_floor():
			velocity += get_gravity() * delta

		var input_dir := Input.get_vector("deets_strafeleft", "deets_straferight", "deets_forward", "deets_backwards")
		if peeking:
			input_dir = -input_dir
		direction = ($Head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		$Head.rotation.z = lerp($Head.rotation.z, input_dir.x / 25, 5 * delta)

		if direction != Vector3.ZERO:
			velocity.x = lerp(velocity.x, (direction.x * currentSpeed) * SaveData.getGameSetting("player", "speed_multiplier"), ACCELERATION * delta)
			velocity.z = lerp(velocity.z, (direction.z * currentSpeed) * SaveData.getGameSetting("player", "speed_multiplier"), ACCELERATION * delta)
		else:
			velocity.x = lerp(velocity.x, 0.0, ACCELERATION * delta)
			velocity.z = lerp(velocity.z, 0.0, ACCELERATION * delta)

		move_and_slide()


func _input(event: InputEvent) -> void:
	if Global.pauseGame:
		return
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if !lerpHeadYToCustom:
		if event is InputEventMouseMotion:
			targetRotY -= event.relative.x * lookSensitviity
			targetRotX -= event.relative.y * lookSensitviity
			targetRotX = clamp(targetRotX, deg_to_rad(-90), deg_to_rad(90))

	if event.is_action_pressed("deets_ui"):
		hidingUI = true
	if event.is_action_released("deets_ui"):
		hidingUI = false


func _playPop():
	$Pop.pitch_scale = randf_range(0.8, 1.2)
	$Pop.play()


func _playPopLowPitched():
	$Pop.pitch_scale = randf_range(0.6, 0.8)
	$Pop.play()


func _onCollected(what, howMuch):
	#print("collected " + str(howMuch) + " " + str(what))
	if what == CollectableArea3D.COLLECTABLE_TYPE.STEEDIUM:
		_playPop()
		Global.currentGameLoop._giveSteedium(howMuch)


func _onCollectRangeEntered(area: Area3D) -> void:
	#print("collect")
	if area is CollectableArea3D:
		area.collected.connect(_onCollected)
		area.aboutToBeCollected.emit()


func _onGun():
	if !interactingWithSomethingElse and !goNumb:
		$Gun.pitch_scale = randf_range(0.9, 1.1)
		$Gun.play()

		if %GunRay.is_colliding():
			var collider = %GunRay.get_collider()
			var yes = true
			if collider is Horse and collider.currentState != collider.STATE.DEAD:
				Global.gameUI_RevealEvent("The [color=brown]horse[/color] is dead for " + ("20" if !Global.currentGameLoop.endGame else "10") + " seconds. Rejoice!", 6.0)
				SaveData._unlockAch("gun")
				collider._die()
				yes = false
			if collider.name.contains("Pedestal") and collider.isInteractable:
				(collider as Pedestal).triggerDestroy()
				SaveData._unlockAch("gun2")
				yes = false
			if yes:
				print("dumb ass missed")
				var nearest = Global.currentLevelGen.findNearestWalkablePos(Vector2(global_position.x, global_position.z))
				Global.currentGameLoop.alertHorseOfSound.emit(Vector3(nearest.x, 0.0, nearest.y))
		else:
			print("dumb ass missed")
			var nearest = Global.currentLevelGen.findNearestWalkablePos(Vector2(global_position.x, global_position.z))
			Global.currentGameLoop.alertHorseOfSound.emit(Vector3(nearest.x, 0.0, nearest.y))
