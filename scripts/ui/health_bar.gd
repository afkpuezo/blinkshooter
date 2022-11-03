extends ProgressBar
class_name HealthBar
## used for both enemies and player - will it just be resized or extended?


## eventually could have a flashy animation
func change_value(new_v, max_v):
	value = new_v
	max_value = max_v


