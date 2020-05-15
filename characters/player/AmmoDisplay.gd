extends Label


func update_ammo(mg_ammo, sg_ammo, rl_ammo):
	text = "-Ammo-\n"
	text += "Machine Gun: \t" + str(mg_ammo) + "\n"
	text += "Shotgun: \t" + str(sg_ammo) + "\n"
	text += "Rocket Launcher: \t" + str(rl_ammo) + "\n"
