extends Area2D

func _ready():
	connect("body_entered", self, "body_entered")

func body_entered(coll):
	LevelManager.load_next_level()
	coll.get_parent().save_data()
