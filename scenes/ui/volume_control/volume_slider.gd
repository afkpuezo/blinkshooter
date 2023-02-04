extends HSlider
class_name VolumeSlider
# based on https://www.gdquest.com/tutorial/godot/audio/volume-slider/


export var audio_bus_name := "Master"
onready var bus_index = AudioServer.get_bus_index(audio_bus_name)


func _ready() -> void:
	value = db2linear(AudioServer.get_bus_volume_db(bus_index))


func on_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(bus_index, linear2db(value))
