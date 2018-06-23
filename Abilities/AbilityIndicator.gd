extends Spatial

func _process(delta):
	var pos = get_parent().get_global_position()
	transform.origin = Vector3(pos.x, 0, pos.y)
	var look = get_parent().getPointTowards()
	look = Vector3(-look.x, 0.0, -look.y) + global_transform.origin + global_transform.origin
	if (look.x != pos.x and look.z != pos.y):
		look_at(look, Vector3(0,1,0))
