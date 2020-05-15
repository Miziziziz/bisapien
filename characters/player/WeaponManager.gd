extends Node2D

onready var cur_weapon = $Pistol

func init(_ammo_storage, held_by):
	for weapon in get_children():
		weapon.init(_ammo_storage, held_by)

func _process(_delta):
	global_rotation = (get_global_mouse_position() - global_position).angle()

func switch_to_pistol():
	cur_weapon = $Pistol

func switch_to_machine_gun():
	cur_weapon = $MachineGun

func switch_to_shotgun():
	cur_weapon = $Shotgun

func switch_to_rocket_launcher():
	cur_weapon = $RocketLauncher

func attack(just_pressed: bool, holding: bool):
	if cur_weapon.has_method("attack"):
		cur_weapon.attack(just_pressed, holding)

func get_cur_weapon_ammo_count():
	return cur_weapon.get_cur_ammo_count()

func get_weapons():
	return get_children()
