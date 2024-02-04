extends CharacterBody3D

@onready var placement_preview_mesh = preload("res://Scenes/placement_preview.tscn")
@onready var inven = $Pivot/Inventory

@export var inventory: player_inventory
@export var itemscenes: item_scenes
@export var speed = 6
@export var rotation_speed = 10
@export var place_cooldown = .1
var direction_facing
var items_in_world = Autoload.items_in_world

var target_velocity = Vector3.ZERO
var target_rotation: Transform3D
var placement_mesh_instance
var can_place = true

var place_rot

func _ready():
	placement_mesh_instance = placement_preview_mesh.instantiate()
	add_child(placement_mesh_instance)


func _physics_process(_delta):
	var direction = Vector3.ZERO
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_down"):
		direction.z += 1
	if Input.is_action_pressed("move_up"):
		direction.z -= 1

	if direction != Vector3.ZERO:
		direction = direction.normalized()
		$Pivot.look_at(position - direction, Vector3.UP)  # mesh rotation
		placement_mesh_instance.target_pos = direction

	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	velocity = target_velocity
	move_and_slide()


func _process(_delta):
	direction_facing = Autoload.get_direction_facing(get_node("Pivot").rotation_degrees)
	if Input.is_action_pressed("remove"):
		remove(placement_mesh_instance.placement_pos)
	if Input.is_action_pressed("place") and can_place:
		place(inven.get_current_item())


func remove(pos):
	var item_name
	if items_in_world.has(pos):
		item_name = items_in_world[pos]["name"]
		items_in_world[pos]["instance"].queue_free()
		items_in_world.erase(pos)
	return item_name


func place(place_item):
	can_place = false
	if inventory[place_item] > 0:
		inventory[place_item] -= 1
		inven.inven_changed.emit()
		var pos = placement_mesh_instance.placement_pos
		var rot = $Pivot.rotation_degrees.snapped(Vector3(0, 90, 0)) + Vector3(0, 90, 0)
		var dir = Autoload.get_direction_facing(rot)
		if items_in_world.has(pos):
			var item = items_in_world[pos]
			if item["name"] == "conveyor" and place_item == "conveyor":
				if item["instance"].direction_facing == dir:
					var lastPos = get_last_pos(pos, dir)
					if lastPos.y != -1:
						create_instance(lastPos, rot, place_item)
					else:
						inventory[place_item] += 1
				else:
					# to replace conveyor
					replace_instance(pos, rot, place_item)
			else:
				# to replace with not conveyor
				replace_instance(pos, rot, place_item)
		else:
			create_instance(pos, rot, place_item)
	await get_tree().create_timer(place_cooldown).timeout
	can_place = true


func replace_instance(pos, rot, place_item):
	var item_name = remove(pos)
	create_instance(pos, rot, place_item)
	inventory[item_name] += 1
	inven.inven_changed.emit()


func get_last_pos(pos, dir):
	var lastPos
	while true:
		match dir:
			"up":
				if items_in_world.has(pos + Vector3(0, 0, -1)):
					var item = items_in_world[pos + Vector3(0, 0, -1)]
					if item["name"] == "conveyor":
						if item["instance"].direction_facing == dir:
							pos += Vector3(0, 0, -1)
						else:
							# to not create instance
							lastPos = Vector3(0, -1, 0)
					else:
						lastPos = pos
				else:
					lastPos = pos + Vector3(0, 0, -1)
			"down":
				if items_in_world.has(pos + Vector3(0, 0, 1)):
					var item = items_in_world[pos + Vector3(0, 0, 1)]
					if item["name"] == "conveyor":
						if item["instance"].direction_facing == dir:
							pos += Vector3(0, 0, 1)
						else:
							lastPos = Vector3(0, -1, 0)
					else:
						lastPos = pos
				else:
					lastPos = pos + Vector3(0, 0, 1)
			"left":
				if items_in_world.has(pos + Vector3(-1, 0, 0)):
					var item = items_in_world[pos + Vector3(-1, 0, 0)]
					if item["name"] == "conveyor":
						if item["instance"].direction_facing == dir:
							pos += Vector3(-1, 0, 0)
						else:
							lastPos = Vector3(0, -1, 0)
					else:
						lastPos = pos
				else:
					lastPos = pos + Vector3(-1, 0, 0)
			"right":
				if items_in_world.has(pos + Vector3(1, 0, 0)):
					var item = items_in_world[pos + Vector3(1, 0, 0)]
					if item["name"] == "conveyor":
						if item["instance"].direction_facing == dir:
							pos += Vector3(1, 0, 0)
						else:
							lastPos = Vector3(0, -1, 0)
					else:
						lastPos = pos
				else:
					lastPos = pos + Vector3(1, 0, 0)
		if lastPos != null:
			break
	return lastPos


func create_instance(pos, rot, place_item):
	var instance = itemscenes[place_item].instantiate()
	instance.get_node("Pivot").rotation_degrees = rot
	instance.position = pos
	get_node("../Items").add_child(instance)
	if items_in_world.has(pos):
		remove(pos)
	items_in_world[pos] = {"name": place_item, "instance": instance}
	return instance
