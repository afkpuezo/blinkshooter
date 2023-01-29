extends CanvasLayer
# singleton


func _ready() -> void:
	# warning-ignore:return_value_discarded
	GameEvents.connect("player_spawned", self, "activate")
	# warning-ignore:return_value_discarded
	GameEvents.connect("player_died", self, "deactivate")
	# warning-ignore:return_value_discarded
	GameEvents.connect("game_won", self, "deactivate")


func activate(_msg = null):
	for c in get_children():
		c.visible = true


func deactivate(_msg = null):
	for c in get_children():
		c.visible = false
