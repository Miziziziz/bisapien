extends KinematicBody2D

onready var anim_player = $AnimationPlayer
onready var health_manager = $HealthManager

enum STATES {IDLE, ATTACK, DEAD}
var cur_state = STATES.IDLE

enum ATTACK_STATES {AIM, CHARGE}
var cur_attack_state = ATTACK_STATES.AIM

export var aim_time = 1.0
export var turn_speed = 360.0
export var charge_speed = 1000
export var charge_time = 4.0

var players = []

signal died

func _ready():
	players = get_tree().get_nodes_in_group("player")
	health_manager.connect("died", self, "set_state_dead")
	health_manager.connect("health_changed", $UI/HealthBar, "update_health")

func _process(delta):
	if cur_state != STATES.ATTACK:
		return
	match cur_attack_state:
		ATTACK_STATES.AIM:
			aim(delta)
		ATTACK_STATES.CHARGE:
			charge(delta)

func set_state_dead():
	cur_state = STATES.DEAD
	anim_player.stop(false)
	emit_signal("died")
	$SmokeParticles.emitting = true
	deactivate_sparks_areas()

var target = null
var cur_attack_time = 0.0
func set_state_attack():
	cur_attack_time = 0.0
	cur_state = STATES.ATTACK
	cur_attack_state = ATTACK_STATES.AIM
	choose_rand_target()
	deactivate_sparks_areas()

func aim(delta):
	anim_player.stop(false)
	anim_player.play("spin", -1, cur_attack_time*4.0)
	
	var r = Vector2.DOWN.rotated(global_rotation)
	var dir_to_target = global_position.direction_to(target.global_position)
	var diff = r.angle_to(dir_to_target)
#	if diff < deg2rad(turn_speed) * delta:
#		global_rotation = global_position.angle_to_point(target.global_position)
#	else:
	global_rotation += deg2rad(turn_speed) * delta * r.dot(dir_to_target)
	
	cur_attack_time += delta
	if cur_attack_time > aim_time:
		cur_attack_state = ATTACK_STATES.CHARGE
		cur_attack_time = 0.0
		activate_sparks_areas()

func charge(delta):
	cur_attack_time += delta
	if cur_attack_time > charge_time:
		cur_attack_state = ATTACK_STATES.AIM
		cur_attack_time = 0.0
		choose_rand_target()
		deactivate_sparks_areas()
	var move_dir = Vector2.RIGHT.rotated(global_rotation)
	move_and_slide(move_dir * charge_speed, Vector2.ZERO)

func choose_rand_target():
	target = players[randi() % players.size()]

func hurt(damage, fired_by=null):
	health_manager.hurt(damage)

onready var sparks_areas = [
	$SparksArea,
	$SparksArea2,
	$SparksArea3
]

func activate_sparks_areas():
	for sparks_area in sparks_areas:
		sparks_area.activated = true

func deactivate_sparks_areas():
	for sparks_area in sparks_areas:
		sparks_area.activated = false
