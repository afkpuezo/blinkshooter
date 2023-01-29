extends CanvasLayer
class_name TriggeredCanvas
## can be toggled on/off by signals


export var enable_delay_time := 0.0
export var disable_delay_time := 0.0


func enable():
	yield(get_tree().create_timer(enable_delay_time, false), "timeout")
	visible = true


func disable():
	yield(get_tree().create_timer(disable_delay_time, false), "timeout")
	visible = false


