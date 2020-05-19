extends Area2D

signal activated
signal deactivated
onready var anim_player = $AnimationPlayer
var is_activated = false

func _ready():
	connect("body_entered", self, "body_entered")
	connect("body_exited", self, "body_exited")

var body_count = 0
func body_entered(_coll):
	body_count+=1
	update_state()
func body_exited(_coll):
	body_count-=1
	update_state()

func update_state():
	if body_count == 0:
		emit_signal("deactivated")
		anim_player.play("idle")
		is_activated = false
	else:
		is_activated = true
		emit_signal("activated")
		anim_player.play("activated")
