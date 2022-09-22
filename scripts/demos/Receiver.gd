extends Node


func _ready() -> void:
	GameEvents.connect("test_event", self, "print_event")


func print_event(msg: Dictionary):
	print(msg['text'])
