extends Node
class_name MovementStats
## Intended as a simple container for movement related stats for a game object
## (eg max speed, acceleration, etc).
## This way, if an object has multiple ways of being moved, there will be one
## clear source of values
## TODO: should this have been some kind of simple object rather than a node?


export var ACCELERATION := 500
export var MAX_SPEED := 100
export(float, 0.0, 1.0) var FRICTION := 0.1 # only applied when no movement input
var velocity := Vector2.ZERO
