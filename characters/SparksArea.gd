extends Area2D

var activated = false
func _process(delta):
	$Particles2D.emitting = get_overlapping_bodies().size() > 0 and activated
