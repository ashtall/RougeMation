extends CharacterBody3D

@onready var placement_preview_mesh = preload("res://Scenes/placement_preview.tscn")

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


func _input(_event):
	#if event.is_action_pressed("place"):
	#place("conveyor")
	#if event.is_action_pressed('remove'):
	#remove()
	pass


func _process(_delta):
	if Input.is_action_pressed("remove"):
		remove()
	if Input.is_action_pressed("place") and can_place:
		place("conveyor")


func place(place_item):
	print(5)
	can_place = false
	if inventory[place_item] > 0:
		inventory[place_item] -= 1
		var instance = itemscenes[place_item].instantiate()
		instance.setRotation($Pivot.rotation_degrees.snapped(Vector3(0, 90, 0)) + Vector3(0, 90, 0))
		get_node("../Items").add_child(instance)
		if Autoload.items_in_world.has(placement_mesh_instance.placement_pos):
			if Autoload.items_in_world[placement_mesh_instance.placement_pos]["name"] == "conveyor":
				instance.position = get_last_conveyor_pos(instance)
			else:
				remove()
				inventory[place_item] += 1
				instance.position = placement_mesh_instance.placement_pos
		else:
			instance.position = placement_mesh_instance.placement_pos
		Autoload.items_in_world[instance.position] = {
			"name": place_item, "instance": instance
		}
		await get_tree().create_timer(place_cooldown).timeout
		can_place = true

func remove():
	if Autoload.items_in_world.has(placement_mesh_instance.placement_pos):
		Autoload.items_in_world[placement_mesh_instance.placement_pos]["instance"].queue_free()
		Autoload.items_in_world.erase(placement_mesh_instance.placement_pos)

func get_last_conveyor_pos(instance):
	var item_positions = Autoload.items_in_world
	var placement_pos = placement_mesh_instance.placement_pos
	var last_pos
	var dir = instance.direction_facing
	while true:
		print(1, dir, 1)
		match dir:
			"up":
				print(2)
				if item_positions.has(placement_pos + Vector3(0, 0, -1)):
					print("yo")
					placement_pos = placement_pos + Vector3(0, 0, -1)
				else:
					print("done")
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
			# var temp = placement_preview_mesh.instantiate()
			# get_node("../Items").add_child(temp)
			# temp.position = last_pos
			break
	return last_pos
