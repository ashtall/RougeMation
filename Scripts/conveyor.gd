extends Node3D

@onready var conveyor = preload("res://Scenes/conveyor_mesh.tscn")
@onready var corner_left_conveyor = preload("res://Scenes/corner_left_conveyor_mesh.tscn")
@onready var corner_right_conveyor = preload("res://Scenes/corner_right_conveyor_mesh.tscn")
@onready var label = $Label3D

@export var item: item_data
@export var direction_facing: String
var directions_can_connect = []
var adjacent_conveyors = []
var input_conveyor
var output_conveyor
var input_dir
var output_dir


func _ready():
	get_direction_facing()
	label.text = direction_facing
	directions_can_connect = get_directions_can_connect()
	update_behind_conveyor()
	adjacent_conveyors = get_adjacent_conveyors()
	for i in adjacent_conveyors:
		if i:
			i.get_adjacent_conveyors()
	tell_perpendicular_conveyors_to_update_behind()

func tell_perpendicular_conveyors_to_update_behind():
	for i in directions_can_connect:
		match i:
			"up":
				if adjacent_conveyors[0]:
					adjacent_conveyors[0].update_behind_conveyor()
					print("up")
			"down":
				if adjacent_conveyors[1]:
					adjacent_conveyors[1].update_behind_conveyor()
					print("down")
			"left":
				if adjacent_conveyors[2]:
					adjacent_conveyors[2].update_behind_conveyor()
					print("left")
			"right":
				if adjacent_conveyors[3]:
					adjacent_conveyors[3].update_behind_conveyor()
					print("right")


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
				"up": {"mesh": corner_right_conveyor, "rotate": 90},
				"down": {"mesh": corner_left_conveyor, "rotate": 90}
			}
		"right":
			return {
				"up": {"mesh": corner_left_conveyor, "rotate": 270},
				"down": {"mesh": corner_right_conveyor, "rotate": 270}
			}
		"up":
			return {
				"left": {"mesh": corner_left_conveyor, "rotate": 0},
				"right": {"mesh": corner_right_conveyor, "rotate": 0}
			}
		"down":
			return {
				"left": {"mesh": corner_right_conveyor, "rotate": 180},
				"right": {"mesh": corner_left_conveyor, "rotate": 180}
			}


func setRotation(angle: Vector3):
	get_node("Pivot").rotation_degrees = angle


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
