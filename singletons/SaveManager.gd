extends Node

var player_data = {}
#var player_data = {
#	"mg_ammo":213, 
#	"player1":{"holding_pistol":false, "main_weapon":1}, 
#	"player2":{"holding_pistol":false, "main_weapon":1}, "rl_ammo":0, "sg_ammo":0}

func get_player_data():
	return player_data

func set_player_data(data):
	player_data = data
