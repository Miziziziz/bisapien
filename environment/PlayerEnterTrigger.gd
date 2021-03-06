extends Area2D

export var both_players = true
export var one_shot = true
var has_signalled = false

signal player_entered
signal player_entered_pass_player_param

func _ready():
	connect("body_entered", self, "on_body_enter")
	connect("body_exited", self, "on_body_exit")

var body_count = 0
func on_body_enter(coll):
	if has_signalled:
		return
	body_count += 1
	if !both_players or (both_players and body_count > 1):
		if one_shot:
			has_signalled = true
		emit_signal("player_entered")
		emit_signal("player_entered_pass_player_param", coll)

func on_body_exit(_coll):
	body_count -= 1
