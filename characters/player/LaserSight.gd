extends Node2D

export var dotted = true
export var laser_color = Color.red
var start_dis = 20
var dot_len = 20
var dot_space_len = 10

func _process(_delta):
	update()

func _draw():
	#draw_string()
	var mouse_pos = get_global_mouse_position()
	var dir_to_cursor = global_position.direction_to(mouse_pos)
	var start_pos = global_position + dir_to_cursor * start_dis
	var space_state = get_world_2d().get_direct_space_state()
	var result = space_state.intersect_ray(start_pos, start_pos + dir_to_cursor * 10000, [], 1+2)
	var end_pos = start_pos + dir_to_cursor * 10000
	if result:
		end_pos = result.position
	
	if dotted:
		var total_dash_len = (dot_len + dot_space_len)
		var dist_to_travel = start_pos.distance_to(end_pos)
		var num_of_segments = int(dist_to_travel) / total_dash_len
		var excess = dist_to_travel - num_of_segments * total_dash_len
		for i in range(num_of_segments):
			var s_pos = total_dash_len * i * dir_to_cursor + start_pos
			draw_line(to_local(s_pos), to_local(s_pos + dir_to_cursor * dot_len), laser_color, 1)
		var s_pos = dir_to_cursor * (dist_to_travel - excess) + start_pos
		if excess < dot_len:
			draw_line(to_local(s_pos), to_local(s_pos + dir_to_cursor * excess), laser_color, 1)
		else:
			draw_line(to_local(s_pos), to_local(s_pos + dir_to_cursor * dot_len), laser_color, 1)
	else:
		draw_line(to_local(start_pos), to_local(end_pos), laser_color, 1)
		#draw_line(to_local(start_pos), to_local(start_pos + dir_to_cursor * 1000), laser_color, 1)
	
	if global_position.distance_squared_to(end_pos) < global_position.distance_squared_to(mouse_pos):
		$Label.set_global_position(end_pos - dir_to_cursor * 60)
	else:
		$Label.set_global_position(mouse_pos - dir_to_cursor * 60)
	
	#draw_circle(to_local(mouse_pos), 5, Color.red)

