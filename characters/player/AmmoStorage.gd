extends Node

class_name AmmoStorage

var machine_gun_ammo_count = 5
var shotgun_ammo_count = 5
var rocket_launcher_ammo_count = 5

func _ready():
	emit_ammo_update_signal()

func pickup_ammo(pickup_type, amount):
	if pickup_type == Pickup.PICKUP_TYPES.MACHINE_GUN_AMMO:
		machine_gun_ammo_count += amount
	if pickup_type == Pickup.PICKUP_TYPES.ROCKET_LAUNCHER_AMMO:
		rocket_launcher_ammo_count += amount
	if pickup_type == Pickup.PICKUP_TYPES.SHOTGUN_AMMO:
		shotgun_ammo_count += amount
	emit_ammo_update_signal()

func dec_mg_ammo():
	if machine_gun_ammo_count > 0:
		machine_gun_ammo_count -= 1
		emit_ammo_update_signal()
		return true
	return false

func dec_sg_ammo():
	if shotgun_ammo_count > 0:
		shotgun_ammo_count -= 1
		emit_ammo_update_signal()
		return true
	return false

func dec_rl_ammo():
	if rocket_launcher_ammo_count > 0:
		rocket_launcher_ammo_count -= 1
		emit_ammo_update_signal()
		return true
	return false

signal ammo_updated
func emit_ammo_update_signal():
	emit_signal("ammo_updated", machine_gun_ammo_count, shotgun_ammo_count, rocket_launcher_ammo_count)
