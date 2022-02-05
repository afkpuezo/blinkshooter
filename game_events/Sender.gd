extends Node


func first_timer():
	GameEvents.emit_signal("test_event", {'text': "First timer triggerred!"})


func second_timer():
	GameEvents.emit_signal("test_event", {'text': "Second timer triggerred!"})
