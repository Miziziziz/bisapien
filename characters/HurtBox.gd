extends Area2D

export var damage = 50

func _ready():
	connect("body_entered", self, "on_body_enter")


func disable():
	$CollisionShape2D.call_deferred("set_disabled", true)

func on_body_enter(coll):
	if coll.has_method("hurt"):
		coll.hurt(damage)
		$Timer.start()

func hurt_all_inside():
	for body in get_overlapping_bodies():
		if body.has_method("hurt") and body != get_parent():
			body.hurt(damage)
	for body in get_overlapping_areas():
		if body.has_method("hurt") and body != get_parent():
			body.hurt(damage)
