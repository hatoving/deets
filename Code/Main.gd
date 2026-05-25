extends Node

var root_scene_path = "res://Scenes/Test.tscn"
var current_scene = null

func _ready():
	#Global.set_game_root(self.get_path())
	change_scene_to_file(root_scene_path)
	
func change_scene_to_file(scene_path):
	if $GameView/Container/Viewport.get_child_count() > 0:
		for i in range($GameView/Container/Viewport.get_child_count()):
			$GameView/Container/Viewport.get_children()[i].queue_free()
	
	var scene : PackedScene = load(scene_path)
	var scene_node = scene.instantiate()
	
	$GameView/Container/Viewport.add_child(scene_node)
	current_scene = scene_node
	
	scene = null

func _process(delta):
	pass
