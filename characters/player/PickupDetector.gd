extends Area2D

signal picked_up_ammo
signal picked_up_health

signal standing_over_weapon
signal not_standing_over_weapon

var max_player_health = 0
var cur_player_health = 0

func update_player_health(_cur_player_health, _max_player_health):
	cur_player_health = _cur_player_health
	max_player_health = _max_player_health

func _ready():
	connect("area_entered", self, "on_area_enter")

func on_area_enter(pickup: Pickup):
	if pickup.pickup_type == Pickup.PICKUP_TYPES.HEALTH:
		if cur_player_health == max_player_health:
			return
		else:
			emit_signal("picked_up_health", pickup.amount)
			$HealthPickup.play()
			pickup.queue_free()
	if pickup.is_ammo():
		emit_signal("picked_up_ammo", pickup.pickup_type, pickup.amount)
		pickup.queue_free()
		$AmmoPickup.play()

var weapon_on_ground = null
func _process(_delta):
	var bodies = get_overlapping_areas()
	if bodies.size() > 0:
		for body in bodies:
			if body is Pickup and body.is_weapon():
				emit_signal("standing_over_weapon", body)
				weapon_on_ground = body
				return
	weapon_on_ground = null
	emit_signal("not_standing_over_weapon")

func pickup_weapon_on_ground():
	if !is_instance_valid(weapon_on_ground):
		return null
	var wep = weapon_on_ground
	weapon_on_ground.get_node("CollisionShape2D").disabled = true
	$WeaponPickup.play()
	weapon_on_ground = null
	return wep
