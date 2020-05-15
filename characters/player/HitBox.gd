extends KinematicBody2D


func hurt(damage: int, fired_by=null):
	get_parent().hurt(damage, fired_by)

func disable():
	for child in get_children():
		if "disabled" in child:
			child.disabled = true
