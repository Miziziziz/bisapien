extends KinematicBody2D

var grenade = preload("res://weapons/Grenade.tscn")

onready var health_manager = $HealthManager
onready var anim_player = $AnimationPlayer
onready var health_bar = $HealthBar
onready var enemy_detector = $EnemyDetector
onready var ally_detector = $AllyDetector

enum STATES {IDLE, WANDER, ATTACK, DEAD}
var cur_state = STATES.IDLE

export var move_speed = 100
onready var wander_timer = $WanderTimer

var can_attack = true
var facing_right = true

func _ready():
	health_manager.connect("died", self, "set_state_dead")
	health_manager.connect("health_changed", health_bar, "update_health")
	health_bar.hide()
	wander_timer.connect("timeout", self, "set_state_wander")

func _process(delta):
	match cur_state:
		STATES.IDLE:
			process_state_idle(delta)
		STATES.WANDER:
			process_state_wander(delta)
		STATES.ATTACK:
			process_state_attack(delta)
		STATES.DEAD:
			process_state_dead(delta)

func set_state_idle():
	cur_state = STATES.IDLE

var wander_count = 0
var num_of_times_to_wander = 3
const MAX_WANDERS = 3
func set_state_wander():
	wander_count += 1
	if wander_count > MAX_WANDERS:
		wander_count = 0
		set_state_attack()
		return
	cur_state = STATES.WANDER
	anim_player.play("walk")
	var dir_of_travel = Vector2.RIGHT.rotated(rand_range(0.0, 2*PI))
	velocity = dir_of_travel * move_speed
	wander_timer.start()

var attack_count = 0
const MAX_ATTACK_COUNT = 4
var target = null
func set_state_attack():
	cur_state = STATES.ATTACK
	attack_count = 0
	play_attack_anim()
	if target.global_position.x < global_position.x and facing_right:
		flip()
	if target.global_position.x > global_position.x and !facing_right:
		flip()
	
func set_state_dead():
	cur_state = STATES.DEAD
	$CollisionShape2D.disabled = true
	$HitBox.disable()
	health_bar.hide()
	anim_player.play("die")
	wander_timer.stop()
	$DeathSound.play()

func process_state_idle(delta):
	var enemy = get_random_visible_enemy()
	if enemy != null:
		target = enemy
		set_state_attack()

var velocity = Vector2.ZERO
func process_state_wander(delta):
	velocity = move_and_slide(velocity, Vector2.ZERO)
	if velocity.length_squared() > 10:
		anim_player.play("walk")
	else:
		anim_player.play("idle")
	if velocity.x < 0 and facing_right:
		flip()
	if velocity.x > 0 and !facing_right:
		flip()

func process_state_attack(delta):
	pass

func process_state_dead(delta):
	pass

func launch_grenade():
	var grenade_inst = grenade.instance()
	get_tree().get_root().add_child(grenade_inst)
	grenade_inst.global_position = global_position
	grenade_inst.init(self, global_position, target.global_position)
	$FireSound.play()

func finish_attack():
	attack_count += 1
	if attack_count >= MAX_ATTACK_COUNT:
		set_state_wander()
	else:
		var enemy = get_random_visible_enemy()
		if enemy:
			target = enemy
		play_attack_anim()
		if target.global_position.x < global_position.x and facing_right:
			flip()
		if target.global_position.x > global_position.x and !facing_right:
			flip()

func hurt(damage: int, fired_by=null):
	if fired_by:
		alert(fired_by)
	health_bar.show()
	health_manager.hurt(damage)

func get_random_visible_enemy():
	var bodies = enemy_detector.get_overlapping_bodies()
	var visible_bodies = []
	for body in bodies:
		if has_los_target_pos(body.global_position):
			visible_bodies.append(body)
	if visible_bodies.size() == 0:
		return null
	return visible_bodies[randi() % visible_bodies.size()]

func has_los_target_pos(target_pos: Vector2):
	var space_state = get_world_2d().get_direct_space_state()
	var result = space_state.intersect_ray(global_position, target_pos, [], 1)
	if result:
		return false
	return true

func play_attack_anim():
	anim_player.play("attack", -1, rand_range(0.9, 1.1))

func flip():
	facing_right = !facing_right
	$Sprite.flip_h = !facing_right

func alert(new_target):
	if new_target == null:
		return
	target = new_target
	if cur_state != STATES.IDLE:
		return
	set_state_attack()
	var nearby_allies = ally_detector.get_overlapping_bodies()
	for ally in nearby_allies:
		ally.alert(new_target)
