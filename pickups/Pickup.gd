extends Area2D

enum PICKUP_TYPES {
	MACHINE_GUN, MACHINE_GUN_AMMO, 
	SHOTGUN, SHOTGUN_AMMO, 
	ROCKET_LAUNCHER, ROCKET_LAUNCHER_AMMO,
	HEALTH
}
export(PICKUP_TYPES) var pickup_type
export var amount = 10

func is_ammo():
	return pickup_type in [
		PICKUP_TYPES.MACHINE_GUN_AMMO, 
		PICKUP_TYPES.SHOTGUN_AMMO, 
		PICKUP_TYPES.ROCKET_LAUNCHER_AMMO
	]

func is_weapon():
	return pickup_type in [
		PICKUP_TYPES.MACHINE_GUN, 
		PICKUP_TYPES.SHOTGUN, 
		PICKUP_TYPES.ROCKET_LAUNCHER
	]

class_name Pickup
