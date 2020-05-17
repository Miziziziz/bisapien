extends Node2D

onready var spawners = get_children()

func _ready():
	for spawner in spawners:
		spawner.connect("done_spawning_pass_target", self, "run_next_spawner")

func run_next_spawner(target):
	if spawners.size() == 0:
		return
	spawners[0].start_spawning(target)
	spawners.pop_front()

