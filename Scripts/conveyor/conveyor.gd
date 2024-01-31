extends Node3D

@onready var label: Label3D = $Label3D

@export var item: item_data
@export var itemScenes: conveyor_scenes
var direction_facing
var resources_on_conveyor = []
var conveyor_speed = .5
var resource_limit = 2
var can_input
var can_output = true
var directions_can_connect = []
var adjacent_conveyors = []


func _ready():
	get_direction_facing()
	directions_can_connect = get_directions_can_connect()
	update_behind_conveyor()
	adjacent_conveyors = get_adjacent_conveyors()
	for i in adjacent_conveyors:
		if i:
			i.get_adjacent_conveyors()
	tell_perpendicular_conveyors_to_update_behind()
	name = "Conveyor " + str(Autoload.conveyor_id)
	Autoload.conveyor_id += 1


func _process(_delta):
	if resources_on_conveyor.size() >= resource_limit:
		can_input = false
	else:
		can_input = true
	if resources_on_conveyor and can_output:
		can_output = false
		give_resource()
	set_debug_resources()


func set_debug_resources():
	label.text = str(can_input) + str(resources_on_conveyor.size()) + "\n"
	for i in resources_on_conveyor:
		if i:
			label.text += i + "\n"


func give_resource():
	if get_next_item(direction_facing):
		if get_next_item(direction_facing)["name"] == "conveyor":
			await get_tree().create_timer(conveyor_speed).timeout
			var conveyor = get_next_item(direction_facing)
			if conveyor["instance"].can_input:
				var resource = resources_on_conveyor.pop_front()
				if resource:
					conveyor["instance"].resources_on_conveyor.append(resource)
					can_output = true
				print(str(resources_on_conveyor) + " " + name)


func tell_perpendicular_conveyors_to_update_behind():
	for i in directions_can_connect:
		match i:
			"up":
				if adjacent_conveyors[0]:
					adjacent_conveyors[0].update_behind_conveyor()
			"down":
				if adjacent_conveyors[1]:
					adjacent_conveyors[1].update_behind_conveyor()
			"left":
				if adjacent_conveyors[2]:
					adjacent_conveyors[2].update_behind_conveyor()
			"right":
				if adjacent_conveyors[3]:
					adjacent_conveyors[3].update_behind_conveyor()


func update_behind_conveyor():
	match direction_facing:
		"up":
			if (
				Autoload.items_in_world.has(position + Vector3(0, 0, 1))
				and Autoload.items_in_world[position + Vector3(0, 0, 1)]["name"] == "conveyor"
			):
				if (
					direction_facing
					in (
						Autoload
						. items_in_world[position + Vector3(0, 0, 1)]["instance"]
						. directions_can_connect
					)
				):
					Autoload.items_in_world[position + Vector3(0, 0, 1)]["instance"].set_mesh(
						direction_facing
					)
		"down":
			if (
				Autoload.items_in_world.has(position - Vector3(0, 0, 1))
				and Autoload.items_in_world[position - Vector3(0, 0, 1)]["name"] == "conveyor"
			):
				if (
					direction_facing
					in (
						Autoload
						. items_in_world[position - Vector3(0, 0, 1)]["instance"]
						. directions_can_connect
					)
				):
					Autoload.items_in_world[position - Vector3(0, 0, 1)]["instance"].set_mesh(
						direction_facing
					)
		"left":
			if (
				Autoload.items_in_world.has(position + Vector3(1, 0, 0))
				and Autoload.items_in_world[position + Vector3(1, 0, 0)]["name"] == "conveyor"
			):
				if (
					direction_facing
					in (
						Autoload
						. items_in_world[position + Vector3(1, 0, 0)]["instance"]
						. directions_can_connect
					)
				):
					Autoload.items_in_world[position + Vector3(1, 0, 0)]["instance"].set_mesh(
						direction_facing
					)
		"right":
			if (
				Autoload.items_in_world.has(position - Vector3(1, 0, 0))
				and Autoload.items_in_world[position - Vector3(1, 0, 0)]["name"] == "conveyor"
			):
				if (
					direction_facing
					in (
						Autoload
						. items_in_world[position - Vector3(1, 0, 0)]["instance"]
						. directions_can_connect
					)
				):
					Autoload.items_in_world[position - Vector3(1, 0, 0)]["instance"].set_mesh(
						direction_facing
					)


func set_mesh(next_direction):
	var pivot = get_node("Pivot")
	var conveyor_mesh
	pivot.get_child(0).queue_free()
	match next_direction:
		"up":
			conveyor_mesh = directions_can_connect.get("up")["mesh"].instantiate()
			pivot.rotation_degrees = Vector3(0, directions_can_connect.get("up")["rotate"], 0)
			pivot.add_child(conveyor_mesh)
		"down":
			conveyor_mesh = directions_can_connect.get("down")["mesh"].instantiate()
			pivot.rotation_degrees = Vector3(0, directions_can_connect.get("down")["rotate"], 0)
			pivot.add_child(conveyor_mesh)
		"left":
			conveyor_mesh = directions_can_connect.get("left")["mesh"].instantiate()
			pivot.rotation_degrees = Vector3(0, directions_can_connect.get("left")["rotate"], 0)
			pivot.add_child(conveyor_mesh)
		"right":
			conveyor_mesh = directions_can_connect.get("right")["mesh"].instantiate()
			pivot.rotation_degrees = Vector3(0, directions_can_connect.get("right")["rotate"], 0)
			pivot.add_child(conveyor_mesh)


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


func get_directions_can_connect():
	match direction_facing:
		"left":
			return {
				"up": {"mesh": itemScenes["corner_right_conveyor"], "rotate": 90},
				"down": {"mesh": itemScenes["corner_left_conveyor"], "rotate": 90}
			}
		"right":
			return {
				"up": {"mesh": itemScenes["corner_left_conveyor"], "rotate": 270},
				"down": {"mesh": itemScenes["corner_right_conveyor"], "rotate": 270}
			}
		"up":
			return {
				"left": {"mesh": itemScenes["corner_left_conveyor"], "rotate": 0},
				"right": {"mesh": itemScenes["corner_right_conveyor"], "rotate": 0}
			}
		"down":
			return {
				"left": {"mesh": itemScenes["corner_right_conveyor"], "rotate": 180},
				"right": {"mesh": itemScenes["corner_left_conveyor"], "rotate": 180}
			}


func setRotation(angle: Vector3):
	get_node("Pivot").rotation_degrees = angle


func get_next_item(direction):
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


func get_adjacent_conveyors():
	var up  # z-1
	var down  # z+1
	var left  # x-1
	var right  # x+1

	if (
		Autoload.items_in_world.has(position - Vector3(0, 0, 1))
		and Autoload.items_in_world[position - Vector3(0, 0, 1)]["name"] == "conveyor"
	):
		up = Autoload.items_in_world[position - Vector3(0, 0, 1)]["instance"]
	if (
		Autoload.items_in_world.has(position + Vector3(0, 0, 1))
		and Autoload.items_in_world[position + Vector3(0, 0, 1)]["name"] == "conveyor"
	):
		down = Autoload.items_in_world[position + Vector3(0, 0, 1)]["instance"]
	if (
		Autoload.items_in_world.has(position - Vector3(1, 0, 0))
		and Autoload.items_in_world[position - Vector3(1, 0, 0)]["name"] == "conveyor"
	):
		left = Autoload.items_in_world[position - Vector3(1, 0, 0)]["instance"]
	if (
		Autoload.items_in_world.has(position + Vector3(1, 0, 0))
		and Autoload.items_in_world[position + Vector3(1, 0, 0)]["name"] == "conveyor"
	):
		right = Autoload.items_in_world[position + Vector3(1, 0, 0)]["instance"]

	return [up, down, left, right]
