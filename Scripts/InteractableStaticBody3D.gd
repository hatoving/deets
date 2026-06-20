class_name InteractableStaticBody3D
extends StaticBody3D

signal onInteract

@export_multiline var hint = ""
@export var outlineWidth: float = 4.0

var targetOutlineWidth: float = 0.0
var isInteractable = true

@onready var mesh: MeshInstance3D = $Mesh
@onready var overlayMat: ShaderMaterial = mesh.material_overlay as ShaderMaterial


func _process(_delta: float) -> void:
	if overlayMat:
		var currentWidth = overlayMat.get_shader_parameter("outline_width")
		overlayMat.set_shader_parameter("outline_width", lerp(currentWidth, targetOutlineWidth, 0.3))
	else:
		overlayMat = ShaderMaterial.new()
		overlayMat.shader = load("res://Shaders/Outline.gdshader")


func setHighlight(yes: bool) -> void:
	if yes:
		overlayMat.set_shader_parameter("outline_color", Color.WHITE)
		targetOutlineWidth = outlineWidth
		Global.gameUI_EnableHint(hint)
	else:
		overlayMat.set_shader_parameter("outline_color", Color.TRANSPARENT)
		targetOutlineWidth = 0.0
		Global.gameUI_DisableHint()
