extends Label


func show_weapon(pickup: Pickup):
	show()
	var base_text = "Press 'E' to pick up "
	match pickup.pickup_type:
		Pickup.PICKUP_TYPES.MACHINE_GUN:
			base_text += "Machine Gun"
		Pickup.PICKUP_TYPES.SHOTGUN:
			base_text += "Shotgun"
		Pickup.PICKUP_TYPES.ROCKET_LAUNCHER:
			base_text += "Rocket Launcher"
	text = base_text
