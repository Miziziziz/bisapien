extends Control

onready var text_lines = get_children()
export var allow_continue = true
func _ready():
	text_lines.pop_back()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	for text_line in text_lines:
		text_line.hide()
	text_lines[0].show()
	text_lines[0].modulate.a = 0.0
	OS.set_window_size(OS.get_screen_size())

var cur_ind = 0
var t = 0
var display_speed = .5
var fading_in = true

func _process(delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	if allow_continue and Input.is_action_just_pressed("continue"):
		LevelManager.load_next_level()
	
	if cur_ind >= text_lines.size():
		return
	t += delta * display_speed
	if fading_in and t >= 1.0:
		t = 1.0
		text_lines[cur_ind].modulate.a = 1.0
		fading_in = false
		
	if !fading_in and t >= 1.0:
		t = 0.0
		fading_in = true
		cur_ind += 1
		t = 0.0
		if cur_ind < text_lines.size():
			text_lines[cur_ind].show()
			text_lines[cur_ind].modulate.a = 0.0
		else:
			return
	text_lines[cur_ind].modulate.a = t
