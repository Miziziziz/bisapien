extends Node2D


export var arc = 20

func _ready():
	var num_of_firepoints = get_child_count()
	var spread_amnt = arc / num_of_firepoints
	var cur_angle = 0
	if num_of_firepoints % 2 == 0: # even num of fp
		cur_angle = -(spread_amnt * (num_of_firepoints / 2) - spread_amnt / 2.0)
	else:
		cur_angle = -spread_amnt * (num_of_firepoints-1) / 2
	
	for child in get_children():
		child.rotation_degrees = cur_angle
		cur_angle += spread_amnt
