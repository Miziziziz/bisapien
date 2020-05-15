extends Node2D

var ammo_scns = [
	preload("res://weapons/Bullet.tscn"),
	preload("res://weapons/Bullet.tscn"),
	preload("res://weapons/Bullet.tscn"),
	preload("res://weapons/Rocket.tscn")
]

enum AMMO_TYPES {PISTOL, MACHINEGUN, SHOTGUN, ROCKET}
export(AMMO_TYPES) var ammo_type

export var automatic = false

var ammo = 100
export var damage = 5

export var attack_rate = 0.05
var attack_timer : Timer
var can_attack = true

var fire_points = []
var ammo_storage : AmmoStorage

signal out_of_ammo
var held_by = null

func init(_ammo_storage, _held_by):
	held_by = _held_by
	ammo_storage = _ammo_storage

func _ready():
	attack_timer = Timer.new()
	attack_timer.wait_time = attack_rate
	attack_timer.connect("timeout", self, "finish_attack")
	attack_timer.one_shot = true
	add_child(attack_timer)
	
	if has_node("FirePoints"):
		fire_points = get_node("FirePoints").get_children()

func attack(just_pressed: bool, holding: bool):
	if !automatic and !just_pressed:
		return
	if automatic and !holding:
		return
	if !can_attack:
		return
	
	if ammo_type == AMMO_TYPES.MACHINEGUN and !ammo_storage.dec_mg_ammo():
		emit_signal("out_of_ammo")
		return
	if ammo_type == AMMO_TYPES.SHOTGUN and !ammo_storage.dec_sg_ammo():
		emit_signal("out_of_ammo")
		return
	if ammo_type == AMMO_TYPES.ROCKET and !ammo_storage.dec_rl_ammo():
		emit_signal("out_of_ammo")
		return
	
	can_attack = false
	if fire_points.size() > 0:
		for fire_point in fire_points:
			var ammo_inst = get_ammo_inst()
			ammo_inst.dir = Vector2.RIGHT.rotated(fire_point.global_rotation)
			ammo_inst.init()
	else:
		var ammo_inst = get_ammo_inst()
		ammo_inst.dir = Vector2.RIGHT.rotated(global_rotation)
		ammo_inst.init(held_by)
	attack_timer.start()

func finish_attack():
	can_attack = true

func get_ammo_inst():
	var ammo_inst = ammo_scns[ammo_type].instance()
	get_tree().get_root().add_child(ammo_inst)
	ammo_inst.global_position = global_position
	ammo_inst.damage = damage
	return ammo_inst

func get_cur_ammo_count():
	if ammo_type == AMMO_TYPES.MACHINEGUN:
		return ammo_storage.machine_gun_ammo_count
	if ammo_type == AMMO_TYPES.SHOTGUN:
		return ammo_storage.shotgun_ammo_count
	if ammo_type == AMMO_TYPES.ROCKET:
		return ammo_storage.rocket_launcher_ammo_count
	return -1
