extends StaticBody2D

onready var anim_player = $AnimationPlayer
export var start_closed = true
var is_open = false

func _ready():
	if start_closed:
		anim_player.play("start_closed")
	else:
		is_open = true
		anim_player.play("start_open")

func open():
	if is_open:
		return
	is_open = true
	anim_player.play("open")
	$OpenSound.play()

func close():
	if !is_open:
		return
	is_open = false
	anim_player.play("close")
	$OpenSound.play()
