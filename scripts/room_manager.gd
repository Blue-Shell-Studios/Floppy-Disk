extends Node2D

signal next_level_ready(_move_offset: Vector2)

const BITS = preload("uid://gbnv60og4kua")
const ROOM = preload("uid://c3xuv3iytwkw")

var new_room_size := Vector2i(22, 12)
var new_compartment_num := 3

var current_room: Node2D
var next_room: Node2D

func _ready() -> void:
	randomize()
	
	# lobby
	current_room = _create_room(Vector2i(22, 12), 1, false, false)
	next_room = _create_room(new_room_size, new_compartment_num)

func _process(delta: float) -> void:
	if get_tree().get_nodes_in_group("bits").size() == 0:
		_generate_coins_inside_next_room(5)
		current_room.open()

func _create_room(room_size: Vector2i, compartment_num: int, is_new_room = true, has_entrance: bool = true) -> Node2D:
	var room_scene = ROOM.instantiate()
	add_child(room_scene)
	
	room_scene.setup(room_size, compartment_num, has_entrance)
	room_scene.connect("player_exit", _on_player_exit)
	
	room_scene.position.x = (GameConfig.SCREEN_SIZE.x - room_size.x * GameConfig.TILE_SIZE) / 2
	if is_new_room:
		room_scene.position.y = current_room.position.y - (room_size.y - 1) * GameConfig.TILE_SIZE
	else:
		room_scene.position.y = (GameConfig.SCREEN_SIZE.y - room_size.y * GameConfig.TILE_SIZE) / 2
		
	return room_scene

func _generate_coins_inside_next_room(num: int) -> void:
	var count := 0
	while count < num:
		var x = randi_range(1, new_room_size.x-1)
		var y = randi_range(1, new_room_size.y-1)
		
		var candidate = Vector2i(x,y)
		if candidate not in next_room.data.barrier_tiles:
			var bit = BITS.instantiate()
			add_child(bit)
			bit.position = (candidate as Vector2) * GameConfig.TILE_SIZE + next_room.position
			count += 1

func _on_player_exit() -> void:
	current_room = next_room
	current_room.close()
	
	next_room = _create_room(new_room_size, new_compartment_num)
	next_level_ready.emit(_get_move_offset())

func _get_move_offset() -> Vector2:
	return current_room.position - (GameConfig.SCREEN_SIZE - (current_room.data.room_size as Vector2) * GameConfig.TILE_SIZE) / 2
