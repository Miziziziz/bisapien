extends KinematicBody2D

const NUM_OF_ROTATION_FRAMES = 32
const ANGLE_BETWEEN_FRAMES = 360 / NUM_OF_ROTATION_FRAMES

var damage = 1
var bodies_to_exclude = []
var speed = 600
var dir = Vector2.RIGHT
var held_by = null

func _ready():
	$Sprite.hide()

func init(_held_by):
	held_by = _held_by
	var angle = rad2deg(dir.angle())
	angle -= ANGLE_BETWEEN_FRAMES / 2 
	if angle < 0.0:
		angle += 360
	var frame_ind = (int(360 - angle) / ANGLE_BETWEEN_FRAMES) % NUM_OF_ROTATION_FRAMES
	$Sprite.frame = frame_ind
	$SmokeBlastParticles2D.rotation = dir.angle() + PI
	$SmokeBlastParticles2D.global_position -= dir * 50

func _physics_process(delta):
	var coll = move_and_collide(dir * speed * delta)
	if coll:
#		queue_free()
		$SmokeParticles2D.emitting=false
		$Explosion/AnimationPlayer.play("blowup")
		$Sprite.hide()
		$CollisionShape2D.disabled=true
		dir = Vector2.ZERO
		$ShowTimer.stop()
		explode()

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
			item_data.collider.hurt(damage, held_by)
