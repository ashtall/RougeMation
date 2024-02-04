extends Node3D

@export var inven: player_inventory
@export var itemscenes: item_meshes

@onready var displaypoint = $Display_item
var real_inven
var display_inven_dic = {}
var display_inven_arr = []
var current_item
var prev_item
var item_switch_cooldown = .1
var can_switch_item = true
var current_item_index = 0

signal inven_changed


func _ready():
	inven.set_inventory()
	real_inven = inven.inventory
	set_display_inven_dic()
	inven_changed.connect(set_display_inven_dic)
	display_item()
	current_item = get_current_item()


func _input(event):
	if event.is_action_pressed("switch_item_left") and can_switch_item:
		switch_item_left()
	if event.is_action_pressed("switch_item_right") and can_switch_item:
		switch_item_right()


func set_display_inven_dic():
	inven.set_inventory()
	real_inven = inven.inventory
	display_inven_arr.clear()
	display_inven_dic.clear()
	for i in real_inven:
		if real_inven[i] > 0:
			display_inven_dic[i] = real_inven[i]
			display_inven_arr.append(i)
	display_item()
	print(inven.inventory)


func switch_item_left():
	if display_inven_arr.size() != 0:
		current_item_index -= 1
		if current_item_index < 0:
			current_item_index = display_inven_arr.size() - 1
		display_item()
		current_item = display_inven_arr[current_item_index]


func switch_item_right():
	if display_inven_arr.size() != 0:
		current_item_index += 1
		if current_item_index > display_inven_arr.size() - 1:
			current_item_index = 0
		display_item()
		current_item = display_inven_arr[current_item_index]


func display_item():
	for i in displaypoint.get_children():
		i.queue_free()
	if display_inven_dic.size() != 0:
		var item = itemscenes[display_inven_arr[current_item_index]].instantiate()
		#displaypoint.add_child(item)


func get_current_item():
	return display_inven_arr[current_item_index]
