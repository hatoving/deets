extends CanvasLayer

@export var game_size : Vector2i

func _ready():
	$Container/Viewport.size = Vector2(game_size.x, game_size.y)
	$Container.size = Vector2(game_size.x, game_size.y)
	get_viewport().connect("size_changed", Callable(self, "_on_viewport_size_changed"))
	_on_viewport_size_changed()
	
func _process(delta):
	# Toggle bilinear filtering on "ui_accept" press
	if $Container/Viewport.size != game_size or $Container.size != Vector2(game_size):
		$Container/Viewport.size = Vector2(game_size.x, game_size.y)
		$Container.size = Vector2(game_size.x, game_size.y)

func _update_filtering(value):
	var viewport = $Container/Viewport
	if viewport:
		var texture = viewport.get_texture()
		if texture:
			if value:
				texture.flags |= texture.FLAG_FILTER
			else:
				texture.flags &= ~texture.FLAG_FILTER


func _on_viewport_size_changed():
	update_game_viewport()
	
func update_game_viewport():
	var screen_size = get_viewport().size
	var vp_size = $Container/Viewport.size
	
	if vp_size.x == 0 or vp_size.y == 0:
		print("Viewport size is zero! Cannot scale properly.")
		return
	
	var scale_x = screen_size.x / vp_size.x
	var scale_y = screen_size.y / vp_size.y
	
	$Container.position = Vector2(0, 0)
	$Container.scale = Vector2(scale_x, scale_y)
