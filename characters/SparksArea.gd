extends Area2D

var grinding_something = false
var activated = false
func _process(_delta):
	grinding_something = get_overlapping_bodies().size() > 0 and activated
	$Particles2D.emitting = grinding_something
