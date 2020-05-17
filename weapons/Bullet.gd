extends KinematicBody2D

const NUM_OF_ROTATION_FRAMES = 32
const ANGLE_BETWEEN_FRAMES = 360 / NUM_OF_ROTATION_FRAMES

var damage = 1
var bodies_to_exclude = []
var speed = 3000
var dir = Vector2.RIGHT
var fired_by = null

func _ready():
	$Sprite.hide()

func init(_fired_by=null):
	fired_by = _fired_by
	var angle = rad2deg(dir.angle())
	angle -= ANGLE_BETWEEN_FRAMES / 2 
	if angle < 0.0:
		angle += 360
	var frame_ind = (int(360 - angle) / ANGLE_BETWEEN_FRAMES) % NUM_OF_ROTATION_FRAMES
	$Sprite.frame = frame_ind

func _physics_process(delta):
	var coll = move_and_collide(dir * speed * delta)
	if coll:
		$BlowupSprite/AnimationPlayer.play("blowup")
		$Sprite.hide()
		$CollisionShape2D.disabled = true
		$ShowTimer.stop()
		$HitSound.play()
		dir = Vector2.ZERO
		if coll.collider.has_method("hurt"):
			coll.collider.hurt(damage, fired_by)
	
	

