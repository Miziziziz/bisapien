extends Label


func _ready():
	hide()
	visible_characters = 0
	$Timer.connect("timeout", self, "add_char")

func start_displaying():
	show()
	$Timer.start()
	$TextSounds.play()

func add_char():
	visible_characters += 1
	if percent_visible >= 1.0:
		$Timer.stop()
		$TextSounds.stop()
	
