extends Node2D

signal level_cleared(new_level: int)
signal next_level_ready(_move_offset: Vector2)

const BITS = preload("uid://gbnv60og4kua")
const ROOM = preload("uid://c3xuv3iytwkw")
const MIN_COMPARTMENT_WIDTH = 4

const VIRUS = preload("uid://cf7cyhpvgjhy0")
const TROJAN = preload("uid://bb5a5fwdt38df")

const TROJAN_COST := 1
const VIRUS_COST := 2
const MAX_ENCOUNTER_BUDGET := 4

var new_room_size := Vector2i(25, 12)
var new_compartment_num := 3

var current_room: Node2D
var next_room: Node2D

var level : int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED

	randomize()

func _process(delta: float) -> void:
	if get_tree().get_nodes_in_group("bits").size() == 0:
		_generate_bits_inside_next_room(5 + level / 3)
		current_room.open()

func _create_room(room_size: Vector2i, compartment_num: int, is_new_room = true, has_entrance: bool = true) -> Node2D:
	var room_scene = ROOM.instantiate()
	add_child(room_scene)

	var difficulty_level := level + 1 if is_new_room else 0
	var enemies := _build_enemy_encounter(difficulty_level)

	room_scene.setup(room_size, compartment_num, enemies, has_entrance, difficulty_level)
	room_scene.connect("player_exit", _on_player_exit)

	var screen_size := GameConfig.get_screen_size(self)
	room_scene.position.x = (screen_size.x - room_size.x * GameConfig.TILE_SIZE) / 2.0
	if is_new_room:
		room_scene.position.y = current_room.position.y - (room_size.y - 1) * GameConfig.TILE_SIZE
	else:
		room_scene.position.y = (screen_size.y - room_size.y * GameConfig.TILE_SIZE) / 2.0

	return room_scene

func _build_enemy_encounter(difficulty_level: int) -> Array:
	if difficulty_level <= 2:
		return []

	if difficulty_level <= 5:
		return [TROJAN] if difficulty_level % 2 == 1 else []

	if difficulty_level <= 8:
		return [VIRUS] if randi() % 4 == 0 else [TROJAN]

	var budget := mini(2 + floori((difficulty_level - 9) / 3.0), MAX_ENCOUNTER_BUDGET)
	var enemies := []

	while budget > 0:
		var can_afford_virus := budget >= VIRUS_COST
		var prefers_virus := difficulty_level >= 10 and randi() % 3 == 0

		if can_afford_virus and prefers_virus:
			enemies.append(VIRUS)
			budget -= VIRUS_COST
		else:
			enemies.append(TROJAN)
			budget -= TROJAN_COST

	enemies.shuffle()
	return enemies

func _generate_bits_inside_next_room(num: int) -> void:
	var valid_coords: Array[Vector2i] = next_room.data.get_collectible_spawn_tiles()

	valid_coords.shuffle()
	var spawn_count := mini(num, valid_coords.size())

	for i in range(spawn_count):
		var candidate = valid_coords[i]
		var bit = BITS.instantiate()
		add_child(bit)

		bit.position = (candidate as Vector2) * GameConfig.TILE_SIZE + next_room.position + Vector2(GameConfig.TILE_SIZE/2, GameConfig.TILE_SIZE/2)

func _progress_level():
	level += 1

	if level % 4 == 0 and new_room_size.x < 37:
		new_room_size.x += new_compartment_num

		if (new_room_size.x - new_compartment_num*2 - 2) / (new_compartment_num * 2) >= MIN_COMPARTMENT_WIDTH:
			new_compartment_num += 2
			new_room_size.x = (MIN_COMPARTMENT_WIDTH + 1) * new_compartment_num + 2

	level_cleared.emit(level)

func _set_next_level():
	current_room = next_room
	current_room.close()
	current_room.summon_enemies()

	next_room = _create_room(new_room_size, new_compartment_num)
	next_level_ready.emit(_get_move_offset())

func _on_player_exit() -> void:
	_progress_level()
	_set_next_level()

func _get_move_offset() -> Vector2:
	var screen_size := GameConfig.get_screen_size(self)
	return current_room.position - (screen_size - (current_room.data.room_size as Vector2) * GameConfig.TILE_SIZE) / 2.0

func _on_game_game_started() -> void:
	current_room = _create_room(Vector2i(22, 12), 1, false, false)
	next_room = _create_room(new_room_size, new_compartment_num)

	process_mode = Node.PROCESS_MODE_INHERIT
