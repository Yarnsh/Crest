extends ImmediateGeometry

func _process(delta):
	var pos = get_parent().get_global_position()
	
	var p = Array(get_parent().polygon)
	clear()
	begin(Mesh.PRIMITIVE_TRIANGLE_FAN, null)
	for x in p:
		add_vertex(global.to3D(x))
	add_vertex(global.to3D(p[0]))
	end()
	
	transform.origin = global.to3D(pos)
	var look = get_parent().get_parent().get_parent().getPointTowards()
	var look3D = global.to3D(look)
	if (look3D.x != pos.x and look3D.z != pos.y):
		look_at(look3D, Vector3(0,1,0))
		rotate_y(PI/2.0)
