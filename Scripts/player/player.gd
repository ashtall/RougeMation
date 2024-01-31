extends CharacterBody3D

@onready var placement_preview_mesh = preload("res://Scenes/placement_preview.tscn")
@onready var inven = $Pivot/Inventory

@export var inventory: player_inventory
@export var itemscenes: item_scenes
@export var speed = 6
@export var rotation_speed = 10
@export var place_cooldown = .1

var target_velocity = Vector3.ZERO
var target_rotation: Transform3D
var placement_mesh_instance
var can_place = true


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
	if Input.is_action_pressed("remove"):
		remove(placement_mesh_instance.placement_pos)
	if Input.is_action_pressed("place") and can_place:
		place(inven.get_current_item())


func place(place_item):
	can_place = false
	if inventory[place_item] > 0:
		inventory[place_item] -= 1
		inven.inven_changed.emit()
		var instance = itemscenes[place_item].instantiate()
		instance.get_node("Pivot").rotation_degrees = (
			$Pivot.rotation_degrees.snapped(Vector3(0, 90, 0)) + Vector3(0, 90, 0)
		)
		get_node("../Items").add_child(instance)
		if Autoload.items_in_world.has(placement_mesh_instance.placement_pos):
			if (
				Autoload.items_in_world[placement_mesh_instance.placement_pos]["name"] == "conveyor"
				and place_item == "conveyor"
			):
				if (
					(
						Autoload
						. items_in_world[placement_mesh_instance.placement_pos]["instance"]
						. direction_facing
					)
					== instance.direction_facing
				):
					instance.position = get_last_conveyor_pos(instance)
				else:
					var item_name = remove(placement_mesh_instance.placement_pos)
					inventory[item_name] += 1
					inven.inven_changed.emit()
					instance.position = placement_mesh_instance.placement_pos
			else:
				var item_name = remove(placement_mesh_instance.placement_pos)
				inventory[item_name] += 1
				inven.inven_changed.emit()
				instance.position = placement_mesh_instance.placement_pos
		else:
			instance.position = placement_mesh_instance.placement_pos
		Autoload.items_in_world[instance.position] = {"name": place_item, "instance": instance}
		await get_tree().create_timer(place_cooldown).timeout
		can_place = true


func remove(pos):
	var item_name
	if Autoload.items_in_world.has(pos):
		item_name = Autoload.items_in_world[pos]["name"]
		Autoload.items_in_world[pos]["instance"].queue_free()
		Autoload.items_in_world.erase(pos)
	return item_name


func get_last_conveyor_pos(instance):
	var item_positions = Autoload.items_in_world
	var placement_pos = placement_mesh_instance.placement_pos
	var last_pos
	var dir = instance.direction_facing
	while true:
		match dir:
			"up":
				if item_positions.has(placement_pos + Vector3(0, 0, -1)):
					placement_pos = placement_pos + Vector3(0, 0, -1)
				else:
					last_pos = placement_pos + Vector3(0, 0, -1)
			"down":
				if item_positions.has(placement_pos + Vector3(0, 0, 1)):
					placement_pos = placement_pos + Vector3(0, 0, 1)
				else:
					last_pos = placement_pos + Vector3(0, 0, 1)
			"left":
				if item_positions.has(placement_pos + Vector3(-1, 0, 0)):
					placement_pos = placement_pos + Vector3(-1, 0, 0)
				else:
					last_pos = placement_pos + Vector3(-1, 0, 0)
			"right":
				if item_positions.has(placement_pos + Vector3(1, 0, 0)):
					placement_pos = placement_pos + Vector3(1, 0, 0)
				else:
					last_pos = placement_pos + Vector3(1, 0, 0)
		if last_pos != null:
			break
	return last_pos
