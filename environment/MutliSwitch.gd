extends Node2D

onready var switches = get_children()

signal activated

func _ready():
	for switch in switches:
		switch.connect("activated", self, "update_state")

func update_state():
	for switch in switches:
		if !switch.is_activated:
			return
	emit_signal("activated")
