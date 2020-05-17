extends KinematicBody2D

var start_pos=Vector2()
var end_pos=Vector2()
const MAX_TIME_IN_AIR = 1.0
const MAX_HEIGHT = 200

var damage = 30
var bodies_to_exclude = []
var speed = 1200
var dir = Vector2.RIGHT
var fired_by = null

func _ready():
	$Sprite.hide()

func init(_fired_by, _start_pos, _end_pos):
	start_pos = _start_pos
	end_pos = _end_pos
	fired_by = _fired_by
	$TargetSprite.global_position = end_pos

var time_in_air = 0.0
var exploded = false
func _physics_process(delta):
	if exploded:
		return
	time_in_air += delta
	if time_in_air >= MAX_TIME_IN_AIR:
		global_position = end_pos
		$SmokeParticles2D.emitting=false
		$Explosion/AnimationPlayer.play("blowup")
		$Sprite.hide()
		$CollisionShape2D.disabled=true
		dir = Vector2.ZERO
		$ShowTimer.stop()
		$TargetSprite.hide()
		explode()
		exploded = true
		$ExplodeSound.play()
	else:
		var t = time_in_air / MAX_TIME_IN_AIR
		var cur_pos = lerp(start_pos, end_pos, t)
		var y = 4.0*(0.25 - (t-.5)*(t-.5))
		cur_pos.y -= y * MAX_HEIGHT
		global_position = cur_pos
		$TargetSprite.global_position = end_pos

func explode():
	var query = Physics2DShapeQueryParameters.new()
	var select_transform = Transform2D()
	select_transform.origin = global_position
	query.set_transform(select_transform)
	query.set_shape($ExplosionShape.shape)
	query.collision_layer = collision_mask
	var space_state = get_world_2d().get_direct_space_state()
	var result = space_state.intersect_shape(query)
	for item_data in result:
		if item_data.collider.has_method("hurt"):
			item_data.collider.hurt(damage, fired_by)
