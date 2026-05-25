extends StaticBody3D

func _process(_delta):
	if Global.currentShop:
		var target_position = Global.currentShop.global_transform.origin
		var my_position = global_transform.origin
		target_position.y = my_position.y

		$Rot.look_at(target_position, Vector3.UP)
