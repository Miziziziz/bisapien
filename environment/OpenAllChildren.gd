extends Node2D


func open():
	for child in get_children():
		if child.has_method("open"):
			child.open()
