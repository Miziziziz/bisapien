extends KinematicBody2D

onready var lower_body = $Graphics/Legs
onready var upper_body = $Graphics/Legs/UpperBody
onready var anim_player = $Graphics/Legs/AnimationPlayer
onready var weapon_manager = $Graphics/Legs/WeaponManager
onready var pickup_detector = $PickupDetector
onready var health_manager = $HealthManager
onready var weapon_name_display = $UI/PopupUI/WeaponName
var facing_right = true

var accel = 100
var drag = 0.9
var velocity : Vector2
var move_vec : Vector2

enum WEAPONS {PISTOL, MACHINE_GUN, SHOTGUN, ROCKET_LAUNCHER}
var main_weapon = null
var holding_pistol = true

func init(_ammo_storage):
	weapon_manager.init(_ammo_storage, self)
	pickup_detector.connect("picked_up_ammo", _ammo_storage, "pickup_ammo")
	for weapon in weapon_manager.get_weapons():
		weapon.connect("out_of_ammo", self, "switch_to_pistol")

func _ready():
	switch_to_pistol()

func attack(just_pressed: bool, holding: bool):
	weapon_manager.attack(just_pressed, holding)
	update_ammo_display()

func _physics_process(_delta):
	velocity += -velocity * drag + accel * move_vec
	velocity = move_and_slide(velocity, Vector2.ZERO)

func _process(_delta):
	if (velocity.x > 0.0 and !facing_right) or (velocity.x < 0.0 and facing_right):
		flip()
	
	var velo_len = velocity.length()
	if velo_len > 0.1:
		anim_player.play("run", -1, velo_len / 100)
	else:
		anim_player.play("idle")

func flip():
	facing_right = !facing_right
	lower_body.flip_h = !facing_right
	upper_body.flip()

func switch_to_pistol():
	weapon_manager.switch_to_pistol()
	upper_body.switch_to_pistol()
	holding_pistol = true
	update_ammo_display()
	weapon_name_display.text = "Pistol"

func switch_to_machine_gun():
	weapon_manager.switch_to_machine_gun()
	upper_body.switch_to_machine_gun()
	holding_pistol = false
	update_ammo_display()
	weapon_name_display.text = "Machine Gun"

func switch_to_shotgun():
	weapon_manager.switch_to_shotgun()
	upper_body.switch_to_shotgun()
	holding_pistol = false
	update_ammo_display()
	weapon_name_display.text = "Shotgun"

func switch_to_rocket_launcher():
	weapon_manager.switch_to_rocket_launcher()
	upper_body.switch_to_rocket_launcher()
	holding_pistol = false
	update_ammo_display()
	weapon_name_display.text = "Rocket Launcher"

func toggle_pistol():
	if main_weapon == null:
		return
	if holding_pistol:
		if main_weapon == WEAPONS.MACHINE_GUN:
			switch_to_machine_gun()
		if main_weapon == WEAPONS.SHOTGUN:
			switch_to_shotgun()
		if main_weapon == WEAPONS.ROCKET_LAUNCHER:
			switch_to_rocket_launcher()
	else:
		switch_to_pistol()

func use():
	var weapon_on_ground = pickup_detector.pickup_weapon_on_ground()
	if weapon_on_ground != null:
		pickup_weapon(weapon_on_ground)
		return

func pickup_weapon(weapon: Pickup):
	if main_weapon != null:
		drop_current_weapon()
	if weapon.pickup_type == Pickup.PICKUP_TYPES.MACHINE_GUN:
		main_weapon = WEAPONS.MACHINE_GUN
		switch_to_machine_gun()
	if weapon.pickup_type == Pickup.PICKUP_TYPES.SHOTGUN:
		main_weapon = WEAPONS.SHOTGUN
		switch_to_shotgun()
	if weapon.pickup_type == Pickup.PICKUP_TYPES.ROCKET_LAUNCHER:
		main_weapon = WEAPONS.ROCKET_LAUNCHER
		switch_to_rocket_launcher()
	weapon.queue_free()


var mg_pickup = preload("res://pickups/MachineGunPickup.tscn")
var sg_pickup = preload("res://pickups/ShotgunPickup.tscn")
var rl_pickup = preload("res://pickups/RocketLauncherPickup.tscn")
func drop_current_weapon():
	if main_weapon == null:
		return
	var thing_to_drop = null
	if main_weapon == WEAPONS.MACHINE_GUN:
		thing_to_drop = mg_pickup
	if main_weapon == WEAPONS.SHOTGUN:
		thing_to_drop = sg_pickup
	if main_weapon == WEAPONS.ROCKET_LAUNCHER:
		thing_to_drop = rl_pickup
	var wep_inst = thing_to_drop.instance()
	get_tree().get_root().add_child(wep_inst)
	wep_inst.global_position = global_position
	wep_inst.add_to_group("instanced")
	main_weapon = null

func update_ammo_display():
	var ammo_count = weapon_manager.get_cur_weapon_ammo_count()
	var ammo_text = str(ammo_count)
	if ammo_count < 0:
		ammo_text = ""
	$UI/PopupUI/AmmoCount.text = ammo_text

func hurt(damage: int, fired_by=null):
	health_manager.hurt(damage)

func load_data(player_data):
	main_weapon = player_data.main_weapon
	if !player_data.holding_pistol:
		toggle_pistol()

func save_data():
	return {
		"main_weapon": main_weapon,
		"holding_pistol": holding_pistol
	}
