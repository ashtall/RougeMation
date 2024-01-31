extends Node3D

# get resource from tile below
#

@onready var output_point = $Pivot/output_point

var resource = "iron"
var direction_facing
var can_extract = true
var is_extracting = false
var resource_hold_limit = 2
var rate_of_extraction = 1
var resource_count = 0


func _ready():
	get_direction_facing()


func _process(_delta):
	if can_extract:
		extracting()
		can_extract = false
	if resource_count > 0:
		give_resource()


func give_resource():
	if get_adjacent_conveyor(direction_facing):
		if get_adjacent_conveyor(direction_facing)["name"] == "conveyor":
			var conveyor = get_adjacent_conveyor(direction_facing)
			if conveyor['instance'].can_input:
				resource_count -= 1
				conveyor['instance'].resources_on_conveyor.append(resource)


func extracting():
	is_extracting = true
	while is_extracting:
		await get_tree().create_timer(rate_of_extraction).timeout
		resource_count += 1
		if resource_count >= resource_hold_limit:
			is_extracting = false


func get_direction_facing():
	match int($Pivot.rotation_degrees.y):
		0:
			direction_facing = "left"
		270:
			direction_facing = "up"
		180:
			direction_facing = "right"
		90:
			direction_facing = "down"
		_:
			direction_facing = "nil"


func get_adjacent_conveyor(direction):
	match direction:
		"up":
			if Autoload.items_in_world.has(position - Vector3(0, 0, 1)):
				return Autoload.items_in_world[position - Vector3(0, 0, 1)]
		"down":
			if Autoload.items_in_world.has(position + Vector3(0, 0, 1)):
				return Autoload.items_in_world[position + Vector3(0, 0, 1)]
		"left":
			if Autoload.items_in_world.has(position - Vector3(1, 0, 0)):
				return Autoload.items_in_world[position - Vector3(1, 0, 0)]
		"right":
			if Autoload.items_in_world.has(position + Vector3(1, 0, 0)):
				return Autoload.items_in_world[position + Vector3(1, 0, 0)]
