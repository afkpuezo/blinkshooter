extends Area2D
class_name EnemyMessager
## When one enemy detects the player, it tells nearby enemies about it using this


export var radius := 128

onready var col_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	col_shape.shape.radius = radius
