extends ImmediateGeometry
#Assumes this is for an actor with a circular collider

func _process(delta):
	if (get_parent().get_parent().ability_user != null):
		var user = get_parent().get_parent().ability_user
		var pos = get_parent().get_parent().get_global_position()
		
		var side_len = user.collider.shape.radius
		var dir = (get_parent().get_parent().point_towards - pos).normalized()
		var side = dir.tangent()
		var dist = get_parent().get_parent().max_range
		
		var old_user_pos = user.get_global_position()
		var col = user.move_and_collide(dir*dist)
		if (col != null):
			dist = (col.position - old_user_pos).length()
		user.set_global_position(old_user_pos)
		
		var p = []
		p.append(side * side_len)
		p.append((side * side_len) + (dir * dist))
		p.append((side * -side_len) + (dir * dist))
		p.append(side * -side_len)
		
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
