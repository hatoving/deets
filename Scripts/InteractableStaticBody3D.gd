extends StaticBody3D
class_name InteractableStaticBody3D

var targetOutlineWidth: float = 0.0

@onready var mesh: MeshInstance3D = $Mesh
@onready var overlayMat: ShaderMaterial = mesh.material_overlay as ShaderMaterial

@export_multiline var hint = ""
@export var outlineWidth : float = 4.0

var isInteractable = true

signal onInteract

func setHighlight(yes: bool) -> void:
	if yes:
		overlayMat.set_shader_parameter("outline_color", Color.WHITE)
		targetOutlineWidth = outlineWidth
		Global.gameUI_EnableHint(hint)
	else:
		overlayMat.set_shader_parameter("outline_color", Color.TRANSPARENT)
		targetOutlineWidth = 0.0		
		Global.gameUI_DisableHint()

func _process(_delta: float) -> void:
	if overlayMat:
		var currentWidth = overlayMat.get_shader_parameter("outline_width")
		overlayMat.set_shader_parameter("outline_width", lerp(currentWidth, targetOutlineWidth, 0.3))
	else:
		overlayMat = ShaderMaterial.new()
		overlayMat.shader = load("res://Shaders/Outline.gdshader")
