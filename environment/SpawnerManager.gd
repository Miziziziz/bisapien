extends Node2D

onready var spawners = get_children()
export var pick_rand_target = false
var targets = []
func _ready():
	targets = get_tree().get_nodes_in_group("player")
	for spawner in spawners:
		spawner.connect("done_spawning_pass_target", self, "run_next_spawner")

func run_next_spawner(target=null):
	if spawners.size() == 0:
		return
	if target == null and pick_rand_target:
		target = targets[randi()%targets.size()]
	spawners[0].start_spawning(target)
	spawners.pop_front()

