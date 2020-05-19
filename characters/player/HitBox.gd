extends KinematicBody2D

var disabled = false
func hurt(damage: int, fired_by=null):
	if disabled:
		return
	get_parent().hurt(damage, fired_by)

func disable():
	disabled = true
	for child in get_children():
		if "disabled" in child:
			child.call_deferred("set_disabled", true) #disabled = true
