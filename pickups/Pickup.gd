extends Area2D

enum PICKUP_TYPES {
	MACHINE_GUN, MACHINE_GUN_AMMO, 
	SHOTGUN, SHOTGUN_AMMO, 
	ROCKET_LAUNCHER, ROCKET_LAUNCHER_AMMO,
	HEALTH
}
export(PICKUP_TYPES) var pickup_type
export var amount = 10
export var flash_color = Color.green
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

func _ready():
	for child in get_children():
		if "Sprite" in child.name:
			child.material = CanvasItemMaterial.new()
			child.material.blend_mode = BLEND_MODE_ADD

var t = 0.0
var dir = 1
var speed = 3.0
func _process(delta):
	t += delta * dir * speed
	if t > 1.0 or t < 0.0:
		t = clamp(t, 0.0, 1.0)
		dir *= -1
	modulate = lerp(Color.white, flash_color, t)
