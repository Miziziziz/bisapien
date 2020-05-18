extends KinematicBody2D


onready var health_manager = $HealthManager
onready var anim_player = $AnimationPlayer
onready var health_bar = $HealthBar
onready var enemy_detector = $EnemyDetector
onready var alien_attractor = $AlienAttractor
onready var alien_repeller = $AlienRepeller

enum STATES {IDLE, CHASE, DEAD}
export(STATES) var cur_state

export var attack_range = 40
export var damage = 5
export var attack_rate = 0.5
onready var attack_timer = $AttackTimer
var can_attack = true

export var accel = 250
export var alignment_amount = .5
export var cohesion_amount = 0.05
export var repel_amount = 0.1
var velocity = Vector2()
var drag = 0.7
onready var nav : Navigation2D
var dir_of_travel = Vector2.ZERO

func _ready():
	if get_parent() is Navigation2D:
		nav = get_parent()
	elif get_parent().get_parent() is Navigation2D:
		nav = get_parent().get_parent()
	health_manager.connect("died", self, "set_state_dead")
	health_manager.connect("health_changed", health_bar, "update_health")
	health_bar.hide()
	attack_timer.wait_time = attack_rate
	attack_timer.connect("timeout", self, "finish_attack")

func _process(delta):
	match cur_state:
		STATES.IDLE:
			process_state_idle(delta)
		STATES.CHASE:
			process_state_chase(delta)
		STATES.DEAD:
			process_state_dead(delta)

func set_state_idle():
	cur_state = STATES.IDLE

func set_state_chase():
	cur_state = STATES.CHASE
	anim_player.play("run", -1, 2.0)
	
func set_state_dead():
	cur_state = STATES.DEAD
	$CollisionShape2D.call_deferred("set_disabled", true)#disabled = true
	$HitBox.call_deferred("disable")
	health_bar.hide()
	anim_player.play("die")
	$DeathSound.play()

var target = null
func process_state_idle(delta):
	var nearest_enemy = get_nearest_visible_enemy()
	if nearest_enemy != null:
		target = nearest_enemy
		set_state_chase()

func process_state_chase(delta):
	var nearest_enemy = get_nearest_visible_enemy()
	if nearest_enemy != null and nearest_enemy != target:
		if has_los_target_pos(target.global_position):
			target = nearest_enemy
		else:
			var dist_to_cur = global_position.distance_squared_to(target.global_position)
			var dist_to_near = global_position.distance_squared_to(nearest_enemy.global_position)
			if dist_to_near < dist_to_cur:
				target = nearest_enemy
	
	var in_attack_range = in_attack_range_of_target()
	if can_attack:
		start_attack()
	move_to_target(delta)


func move_to_target(delta):
	if nav == null or target == null:
		return
	var path = nav.get_simple_path(global_position, target.global_position)
	dir_of_travel = Vector2.ZERO
	if path.size() > 1:
		dir_of_travel = global_position.direction_to(path[1])
	
	var aliens_to_attract = alien_attractor.get_overlapping_bodies()
	var aliens_to_repel = alien_repeller.get_overlapping_bodies()
	
	if aliens_to_attract.size() > 0:
		var avg_heading = Vector2.ZERO
		var avg_pos = Vector2.ZERO
		for alien in aliens_to_attract:
			avg_heading += alien.dir_of_travel
			avg_pos += alien.global_position
		avg_heading /= aliens_to_attract.size()
		avg_pos /= aliens_to_attract.size()
		var cohesion_dir = global_position.direction_to(avg_pos)
		dir_of_travel = dir_of_travel * (1.0 - alignment_amount) + avg_heading * alignment_amount 
		dir_of_travel = dir_of_travel * (1.0 - cohesion_amount) + cohesion_dir * cohesion_amount 
	
	if aliens_to_repel.size() > 0:
		var repel_vec = Vector2()
		for alien in aliens_to_repel:
			repel_vec += alien.global_position.direction_to(global_position)
		repel_vec /= aliens_to_repel.size()
		dir_of_travel = dir_of_travel * (1.0 - repel_amount) + repel_vec * repel_amount 
	
	velocity += accel * dir_of_travel - velocity * drag
	velocity = move_and_slide(velocity, Vector2.ZERO)
	
	if target.global_position.x < global_position.x and facing_right:
		flip()
	if target.global_position.x > global_position.x and !facing_right:
		flip()

func process_state_dead(delta):
	pass

func start_attack():
	can_attack = false
	attack_timer.start()

func finish_attack():
	can_attack = true
	if in_attack_range_of_target():
		target.hurt(damage, self)
		$AttackSound.play()

func hurt(damage: int, fired_by=null):
	if fired_by:
		alert(fired_by)
	health_bar.show()
	health_manager.hurt(damage)

func get_nearest_visible_enemy():
	var bodies = enemy_detector.get_overlapping_bodies()
	var closest_body = null
	var dist = -1
	for body in bodies:
		var t_dist = global_position.distance_squared_to(body.global_position)
		if (dist < 0 or t_dist < dist) and has_los_target_pos(body.global_position):
			dist = t_dist
			closest_body = body
	return closest_body

func has_los_target_pos(target_pos: Vector2):
	var space_state = get_world_2d().get_direct_space_state()
	var result = space_state.intersect_ray(global_position, target_pos, [], 1)
	if result:
		return false
	return true

func in_attack_range_of_target():
	if target == null:
		return false
	return global_position.distance_squared_to(target.global_position) < attack_range * attack_range
	

var facing_right = true
func flip():
	facing_right = !facing_right
	$Sprite.flip_h = !facing_right

func alert(new_target):
	if new_target == null:
		return
	target = new_target
	if cur_state != STATES.IDLE:
		return
	set_state_chase()
	var nearby_allies = alien_attractor.get_overlapping_bodies()
	for ally in nearby_allies:
		ally.alert(new_target)
