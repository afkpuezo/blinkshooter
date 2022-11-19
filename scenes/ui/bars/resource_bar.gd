extends ProgressBar
class_name ResourceBar
## used for both enemies and player - will it just be resized or extended?


func change_value(v, max_v = max_value):
	value = v
	max_value = max_v

