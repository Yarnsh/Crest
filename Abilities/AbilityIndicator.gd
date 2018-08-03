extends ImmediateGeometry

func _process(delta):
	var pos = get_parent().get_global_position()
	var p = Array(get_parent().polygon)
	clear()
	begin(Mesh.PRIMITIVE_TRIANGLE_FAN, null)
	for x in p:
		add_vertex(Vector3(x.x + pos.x, 0, x.y + pos.y))
	add_vertex(Vector3(p[0].x + pos.x, 0, p[0].y + pos.y))
	end()
