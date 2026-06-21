class_name Haykeeper
extends Sprite3D

@export var lights: Node3D
@export var music: AudioStreamPlayer3D

@export_category("Sprites")
@export var idle_sprites: Array[Texture2D]
@export var no_equity_sprites: Array[Texture2D]
@export var equity_sprites: Array[Texture2D]
@export var mad_sprites: Array[Texture2D]
@export var closed_sprite: Texture2D
@export var uh_oh_sprite: Texture2D

@export_category("Dialogue")
@export var diag_welcome: AudioStream
@export var diag_welcome_walk_away: AudioStream
@export var diag_welcome_walk_back: AudioStream
@export var diag_come_back: Array[AudioStream]
@export var diag_mad: Array[AudioStream]
@export var diag_equity: Array[AudioStream]
@export var diag_closed: Array[AudioStream]

enum State {
	IDLE,
	NO_EQUITY,
	EQUITY,
	CLOSED,
	MAD,
	UH_OH
}
var state: State = State.MAD
var has_interacted_with_shop: bool = false

var no_welcome: bool = false
var first_welcome: bool = false
var first_walked_away: bool = false
var first_walked_back: bool = false
var disable_come_back: bool = true
var no_buy_counter: int = -1

var timer: float = 0.0
var index: int = 0
var count: int = 0

func on_shop_leave():
	pass

func switch_state(new_state: State, new_timer: float = 0.0):
	state = new_state
	
	index = 0
	count = randi_range(1, 3)
	
	scale.x = 0.732
	scale.y = 0.452
	
	timer = new_timer
	
	if new_state == State.UH_OH:
		$Breathing.pitch_scale = randf_range(0.7, 1.3)
		$Breathing.play()
		$Dialogue.stream_paused = true
		lights.visible = false
	else:
		$Dialogue.stream_paused = false
		$Breathing.stop()
		lights.visible = true

func equity() -> void:
	if no_buy_counter <= 2:
		no_buy_counter = 0
	$Dialogue.stream = diag_equity[randi_range(0, diag_equity.size() - 1)]
	$Dialogue.play()
	
func closed() -> void:
	$Dialogue.stream = diag_closed[randi_range(0, diag_closed.size() - 1)]
	$Dialogue.play()

func come_back() -> void:
	if no_buy_counter > -1 and no_buy_counter < 2:
		disable_come_back = false
	if disable_come_back:
		return
	$Dialogue.stream = diag_come_back[no_buy_counter]
	$Dialogue.play()

func mad() -> void:
	no_buy_counter += 1
	if no_buy_counter >= 2:
		disable_come_back = true
	if no_buy_counter <= 2:
		$Dialogue.stream = diag_mad[no_buy_counter]
	else:
		$Dialogue.stream = diag_mad[randi_range(0, diag_mad.size() - 1)]
	$Dialogue.play()

func _ready() -> void:
	if Global.met_haykeeper:
		no_welcome = true
	timer = randf_range(1.0, 4.5)

func _process(delta: float) -> void:
	scale = lerp(scale, Vector3.ONE * 0.565, 4.0 * delta)
	
	if state == State.UH_OH:
		lights.hide()
		music.stream_paused = true
	
	match state:
		State.IDLE:
			texture = idle_sprites[randi_range(0, idle_sprites.size() - 1)]
		State.EQUITY:
			texture = equity_sprites[randi_range(0, equity_sprites.size() - 1)]
		State.CLOSED:
			texture = closed_sprite
		State.NO_EQUITY:
			if timer > 0.0:
				timer -= delta
				texture = no_equity_sprites[0]
			else:
				var glitch_time := randf_range(.25, .5)
				while glitch_time > 0.0:
					texture = no_equity_sprites[randi_range(1, no_equity_sprites.size() - 1)]
					glitch_time -= delta
					await get_tree().process_frame
				timer = randf_range(0.5, 5.0)
		State.MAD:
			if timer > 0.0:
				timer -= delta
				texture = mad_sprites[0]
			else:
				if count > 0:
					count -= 1
				var uh_oh: int = randi_range(0, 256)
				if uh_oh == 256: 
					switch_state(State.UH_OH, randf_range(1.0, 4.5))
					return
				var glitch_time := randf_range(.25, .5)
				while glitch_time > 0.0:
					texture = mad_sprites[randi_range(1, mad_sprites.size() - 1)]
					lights.visible = !bool(randi_range(0, 1))
					scale.x = 0.732 * randf_range(0.8, 1.1)
					scale.y = 0.452 * randf_range(1.0, 1.1)
					glitch_time -= delta
					
					$Glitch.pitch_scale = randf_range(0.8, 1.2)
					$Glitch.play()
					
					await get_tree().process_frame
				lights.visible = true
				timer = randf_range(0.5, 2.5)
				if count <= 0:
					switch_state(State.IDLE)
		State.UH_OH:
			texture = uh_oh_sprite
			scale = Vector3.ONE * 0.565
			if timer > 0.0:
				timer -= delta
			else:
				timer = randf_range(0.5, 2.5)
				switch_state(State.IDLE)

func _on_area_body_entered(body: Node3D) -> void:
	if body is Player:
		if !has_interacted_with_shop:
			if !Global.met_haykeeper:
				Global.met_haykeeper = true
			if no_welcome:
				return
			if !first_walked_back and first_welcome:
				first_walked_back = true
				$Dialogue.stream = diag_welcome_walk_back
				$Dialogue.play()
			if !first_welcome:
				first_welcome = true
				$Dialogue.stream = diag_welcome
				$Dialogue.play()

func _on_area_body_exited(body: Node3D) -> void:
	if body is Player:
		if !has_interacted_with_shop:
			if no_welcome:
				return
			if first_welcome and !first_walked_away:
				first_walked_away = true
				$Dialogue.stream = diag_welcome_walk_away
				$Dialogue.play()
