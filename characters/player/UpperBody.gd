extends Node2D

const NUM_OF_ROTATION_FRAMES = 24
const ANGLE_BETWEEN_FRAMES = 360 / NUM_OF_ROTATION_FRAMES
onready var cur_weapon_sprite : Sprite = $Pistol

func hide_all_weapons():
	for child in get_children():
		child.hide()

func switch_to_pistol():
	switch_to_weapon($Pistol)

func switch_to_machine_gun():
	switch_to_weapon($MachineGun)

func switch_to_shotgun():
	switch_to_weapon($Shotgun)

func switch_to_rocket_launcher():
	switch_to_weapon($RocketLauncher)

func switch_to_weapon(weapon_node):
	hide_all_weapons()
	cur_weapon_sprite = weapon_node
	cur_weapon_sprite.show()

func _process(_delta):
	var offset_to_cursor = get_global_mouse_position() - global_position
	var angle = rad2deg(offset_to_cursor.angle())
	angle -= ANGLE_BETWEEN_FRAMES / 2 
	if angle < 0.0:
		angle += 360
	var frame_ind = (int(360 - angle) / ANGLE_BETWEEN_FRAMES) % NUM_OF_ROTATION_FRAMES
	if !facing_right:
		frame_ind = NUM_OF_ROTATION_FRAMES - frame_ind + NUM_OF_ROTATION_FRAMES / 2
		frame_ind %= NUM_OF_ROTATION_FRAMES
	cur_weapon_sprite.frame = frame_ind

var facing_right = true
func flip():
	facing_right = !facing_right
	for child in get_children():
		child.flip_h = !facing_right
