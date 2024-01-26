extends Node3D

@export var target_pos: Vector3
@export var placement_pos : Vector3
var step = 1


func _process(_delta):
	position = target_pos
	placement_pos = snapped(global_position, Vector3(step, 0, step))
	global_position = placement_pos
