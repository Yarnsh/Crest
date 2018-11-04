extends ImmediateGeometry

func _process(delta):
	var pos = get_parent().get_global_position()
	
	var dir = get_parent().cast_to.normalized()
	var side = dir.tangent()
	var dist = get_parent().cast_to.length()
	
	if (get_parent().is_colliding()):
		dist = (get_parent().get_collision_point() - pos).length()
	
	var p = []
	p.append(side * 5.0)
	p.append((side * 5.0) + (dir * dist))
	p.append((side * -5.0) + (dir * dist))
	p.append(side * -5.0)
	
	clear()
	begin(Mesh.PRIMITIVE_TRIANGLE_FAN, null)
	for x in p:
		add_vertex(global.to3D(x))
	add_vertex(global.to3D(p[0]))
	end()
	
	transform.origin = global.to3D(pos)
