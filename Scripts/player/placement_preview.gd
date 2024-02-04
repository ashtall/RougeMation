extends Node3D

@export var itemMeshes: item_meshes
var target_pos: Vector3
var global_pos
var placement_pos: Vector3
var prev_pos
var step = 1
var inventory
var current_item
var prev_item
var preview_item
var change_pos = false
var t = 0.0
var current_snapped_position = snapped(global_position, Vector3(step, 0, step))
var pos

func _ready():
	inventory = get_parent().get_node("Pivot/Inventory")
	current_item = inventory.current_item
	change_preview()
	prev_item = current_item


func _process(_delta):
	global_pos = global_position
	rotation_degrees = (
		get_parent().get_node("Pivot").rotation_degrees.snapped(Vector3(0, 90, 0))
		+ Vector3(0, 90, 0)
	)

	position = target_pos
	placement_pos = snapped(global_position, Vector3(step, 0, step))
	global_position = placement_pos

	if !Autoload.items_in_world.has(placement_pos):
		preview_item.global_position = placement_pos

	current_item = inventory.current_item
	if current_item != prev_item:
		change_preview()
		prev_item = current_item

	if Autoload.items_in_world.has(placement_pos):
		change_pos = false
		if (
			Autoload.items_in_world[placement_pos]["name"] == "conveyor"
			and (
				Autoload.items_in_world[placement_pos]["instance"].direction_facing
				== Autoload.get_direction_facing(rotation_degrees)
			)
			and get_parent().get_node("Pivot/Inventory").current_item == "conveyor"
		):
			pos = get_parent().get_last_pos(
				placement_pos, Autoload.get_direction_facing(rotation_degrees)
			)
			preview_item.global_position = pos


func change_preview():
	for i in get_children():
		i.queue_free()
	preview_item = itemMeshes[current_item].instantiate()
	preview_item.transparency = .3
	add_child(preview_item)
