extends Node2D


var min_speed = 100
var max_speed = 400

var cur_dist = 0
var dist_inc = 20
var min_dist = 30
var max_dist_for_speed_calc = 400

onready var player1 = $PlayerCharacter
onready var player2 = $PlayerCharacter2

onready var cam = $Camera2D
onready var ammo_storage = $AmmoStorage


func _ready():
	player1.init(ammo_storage)
	player2.init(ammo_storage)
	cur_dist = player1.global_position.distance_to(player2.global_position)
	load_data()

func _process(_delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("restart"):
		get_tree().call_group("instanced", "queue_free")
		get_tree().reload_current_scene()
	
	var attack_left = Input.is_action_just_pressed("attack_left")
	var attack_left_held = Input.is_action_pressed("attack_left")
	var attack_right = Input.is_action_just_pressed("attack_right")
	var attack_right_held = Input.is_action_pressed("attack_right")
	player1.attack(attack_left, attack_left_held)
	player2.attack(attack_right, attack_right_held)
	
	if Input.is_action_just_pressed("use"):
		player1.use()
		player2.use()
	
	if Input.is_action_just_pressed("switch_weapon_left"):
		player1.toggle_pistol()
	if Input.is_action_just_pressed("switch_weapon_right"):
		player2.toggle_pistol()

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_WHEEL_UP:
			move_closer_together()
		if event.button_index == BUTTON_WHEEL_DOWN:
			move_farther_apart()

func _physics_process(_delta):
	var move_vec = Vector2()
	if Input.is_action_pressed("move_left"):
		move_vec += Vector2.LEFT
	if Input.is_action_pressed("move_right"):
		move_vec += Vector2.RIGHT
	if Input.is_action_pressed("move_down"):
		move_vec += Vector2.DOWN
	if Input.is_action_pressed("move_up"):
		move_vec += Vector2.UP
	move_vec = move_vec.normalized()
	var vec_from_p1_to_p2 = player2.global_position - player1.global_position
	var p_dist = vec_from_p1_to_p2.length()
	var cur_speed = lerp(min_speed, max_speed, clamp(p_dist, min_dist, max_dist_for_speed_calc) / max_dist_for_speed_calc)
	handle_movement(player1, move_vec, vec_from_p1_to_p2, cur_speed)
	handle_movement(player2, move_vec, -vec_from_p1_to_p2, cur_speed)
	update()
	
	var center_pos = vec_from_p1_to_p2 / 2 + player1.global_position
	var mouse_pos = get_global_mouse_position()
	var offset = mouse_pos - center_pos
	cam.global_position = center_pos + offset / 2

func handle_movement(character: KinematicBody2D, move_vec: Vector2, vec_to_other: Vector2, move_speed: float):
	var mouse_pos = get_global_mouse_position()
	var char_pos = character.global_position
	
	var mid_point = vec_to_other / 2 + char_pos
	var center_dir_to_mouse = mid_point.direction_to(mouse_pos)
	var dot_to_char = center_dir_to_mouse.dot(-vec_to_other/2)
	
	var rotation_locked = Input.is_action_pressed("lock_rotation")
	
	if !rotation_locked:
		if dot_to_char > 3:
			var tangent = vec_to_other.rotated(PI/2).normalized()
			if tangent.dot(-center_dir_to_mouse) < 0:
				tangent *= -1
			move_vec += tangent
		if dot_to_char < -3:
			var tangent = vec_to_other.rotated(PI/2).normalized()
			if tangent.dot(center_dir_to_mouse) < 0:
				tangent *= -1
			move_vec += tangent

	var p_dist_diff = cur_dist - player1.global_position.distance_to(player2.global_position)
	if abs(p_dist_diff) > 10:
		move_vec += vec_to_other.normalized() * sign(p_dist_diff) * -1
	
	var move_vec_len = move_vec.length()
	if move_vec_len > 1.0:
		move_vec / move_vec_len
	character.accel = move_speed
	character.move_vec = move_vec

func _draw():
	var vec_from_p1_to_p2 = player2.global_position - player1.global_position
	var center_position = player1.global_position + vec_from_p1_to_p2 / 2.0
	var dir_to_cursor = center_position.direction_to(get_global_mouse_position())
	var dir_to_side = dir_to_cursor.rotated(PI/2)
	var dis_vec = dir_to_side.normalized() * cur_dist / 2.0
	$TargetPosCircle1.global_position = center_position + dis_vec
	$TargetPosCircle2.global_position = center_position - dis_vec
	#draw_empty_circle(center_position + dis_vec, 4.0, Color.yellow, 1)
	#draw_empty_circle(center_position - dis_vec, 4.0, Color.yellow, 1)

func move_closer_together():
	cur_dist -= dist_inc
	if cur_dist < min_dist:
		cur_dist = min_dist

func move_farther_apart():
	cur_dist += dist_inc

func draw_empty_circle(circle_center : Vector2, circle_radius : float, color : Color, resolution: int):
	var draw_counter = 1
	var line_origin = Vector2()
	var line_end = Vector2()
	var circle_radius_vec = Vector2.RIGHT * circle_radius
	line_origin = circle_radius_vec + circle_center

	while draw_counter <= 360:
		line_end = circle_radius_vec.rotated(deg2rad(draw_counter)) + circle_center
		draw_line(line_origin, line_end, color)
		draw_counter += 1 / resolution
		line_origin = line_end

	line_end = circle_radius_vec.rotated(deg2rad(360)) + circle_center
	draw_line(line_origin, line_end, color)

func load_data():
	var player_data = SaveManager.get_player_data()
	if player_data.size() == 0:
		return
	ammo_storage.machine_gun_ammo_count = player_data.mg_ammo
	ammo_storage.shotgun_ammo_count = player_data.sg_ammo
	ammo_storage.rocket_launcher_ammo_count = player_data.rl_ammo
	player1.load_data(player_data.player1)
	player2.load_data(player_data.player2)
	ammo_storage.emit_ammo_update_signal()

func save_data():
	var player_data = {}
	player_data.mg_ammo = ammo_storage.machine_gun_ammo_count
	player_data.sg_ammo = ammo_storage.shotgun_ammo_count
	player_data.rl_ammo = ammo_storage.rocket_launcher_ammo_count
	player_data.player1 = player1.save_data()
	player_data.player2 = player2.save_data()
	SaveManager.set_player_data(player_data)
