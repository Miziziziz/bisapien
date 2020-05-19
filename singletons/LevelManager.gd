extends Node

var level_ind = 0
var level_list = [
	"res://levels/IntroScreen.tscn",
	"res://levels/Tutorial.tscn",
	"res://levels/Level1.tscn",
	"res://levels/Level2.tscn",
	"res://levels/Level3.tscn",
	"res://levels/BossFight.tscn",
	"res://levels/EndScreen.tscn"
]

func load_next_level():
	level_ind += 1
	get_tree().call_group("instanced", "queue_free")
	get_tree().change_scene(level_list[level_ind % level_list.size()])
	$LevelStartSound.play()
