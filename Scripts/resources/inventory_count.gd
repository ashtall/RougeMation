extends Resource
class_name player_inventory

@export var conveyor: int
@export var extractor: int
var inventory: Dictionary


func set_inventory():
	inventory = {"conveyor": conveyor, "extractor": extractor}
