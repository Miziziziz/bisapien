extends Node

var level_ind = 0
var level_list = [
	"res://levels/Tutorial.tscn",
	"res://levels/Level1.tscn",
	"res://levels/Level2.tscn"
]

func load_next_level():
	level_ind += 1
	get_tree().change_scene(level_list[level_ind % level_list.size()])
	$LevelStartSound.play()
