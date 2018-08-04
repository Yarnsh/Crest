extends ImmediateGeometry

func _process(delta):
	var pos = get_parent().get_global_position()
	
	var p = Array(get_parent().polygon)
	clear()
	begin(Mesh.PRIMITIVE_TRIANGLE_FAN, null)
	for x in p:
		add_vertex(Vector3(x.x, 0, x.y))
	add_vertex(Vector3(p[0].x, 0, p[0].y))
	end()
	
	transform.origin = Vector3(pos.x, 0, pos.y)
	var look = get_parent().get_parent().get_parent().getPointTowards()
	look = Vector3(look.x, 0.0, look.y)
	if (look.x != pos.x and look.z != pos.y):
		look_at(look, Vector3(0,1,0))
		rotate_y(PI/2.0)
