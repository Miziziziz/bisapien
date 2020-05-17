extends Node2D

export var spawn_rate = 0.8
export var num_to_spawn = 10
onready var spawn_timer = $SpawnTimer
onready var anim_player = $AnimationPlayer
var amount_spawned = 0
var spawning = false

signal done_spawning
signal done_spawning_pass_target

func _ready():
	spawn_timer.wait_time = spawn_rate

var alien = preload("res://characters/Alien.tscn")
var target = null
func start_spawning(_target=null):
	if spawning:
		return
	spawning = true
	anim_player.play("open")
	target = _target
	$SpawnSound.play()

func spawn_alien():
	if amount_spawned >= num_to_spawn:
		emit_signal("done_spawning")
		emit_signal("done_spawning_pass_target", target)
		return
	spawn_timer.start()
	amount_spawned += 1
	var alien_inst = alien.instance()
	get_parent().add_child(alien_inst)
	alien_inst.global_position = global_position
	if target != null:
		alien_inst.alert(target)
