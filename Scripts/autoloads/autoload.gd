extends Node
class_name autoload

@export var items_in_world = {}
var conveyor_id = 0


func get_direction_facing(rot):
	match int(rot.y):
		0:
			return "left"
		-90:
			return "up"
		270:
			return "up"
		180:
			return "right"
		-180:
			return "right"
		90:
			return "down"
		_:
			return "nil"
