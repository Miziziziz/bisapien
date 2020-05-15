extends Node2D

export var max_health = 100
var cur_health

signal hurt
signal died
signal healed
signal health_changed

func _ready():
	cur_health = max_health
	emit_signal("health_changed", cur_health, max_health)

func hurt(damage: int):
	if cur_health < 0:
		return
	cur_health -= damage
	emit_signal("hurt")
	if cur_health <= 0:
		emit_signal("died")
	emit_signal("health_changed", cur_health, max_health)

func heal(amnt: int):
	cur_health += amnt
	emit_signal("healed")
	if cur_health > max_health:
		cur_health = max_health
	emit_signal("health_changed", cur_health, max_health)
