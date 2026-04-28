class_name RoomData extends RefCounted

const PIPE_THICKNESS = 1
const OPENING_WIDTH = 4
const GAP_HEIGHT = 4
const DOUBLE_GAP_HEIGHT = 3

enum Pattern {
	RANDOM_PIPES,
	ALTERNATING_PIPES,
	CENTER_SHAFT,
	DOUBLE_GAP_PIPES,
	OPEN_ARENA,
}

var room_size : Vector2i
var barrier_tiles : Array[Vector2i] = []
var entrance_tiles : Array[Vector2i] = []
var exit_tiles : Array[Vector2i] = []
var pattern: int = Pattern.RANDOM_PIPES

var enemies : Array

func _init(
	_room_size: Vector2i,
	compartment_num: int,
	_enemies: Array = [],
	has_entrance: bool = true,
	difficulty_level: int = 0
) -> void:
	room_size = _room_size
	enemies = _enemies
	barrier_tiles = []
	entrance_tiles = []
	exit_tiles = []
	pattern = _choose_pattern(compartment_num, difficulty_level)

	_construct_border(has_entrance)
	_construct_obstacles(compartment_num)

func get_collectible_spawn_tiles() -> Array[Vector2i]:
	var fallback_tiles: Array[Vector2i] = []
	var safe_tiles: Array[Vector2i] = []
	var risky_tiles: Array[Vector2i] = []
	var center_x := room_size.x / 2

	for x in range(1, room_size.x - 1):
		for y in range(1, room_size.y - 1):
			var tile_pos := Vector2i(x, y)
			if tile_pos in barrier_tiles or tile_pos in exit_tiles or tile_pos in entrance_tiles:
				continue

			fallback_tiles.append(tile_pos)

			if y >= room_size.y - 2 or abs(x - center_x) <= OPENING_WIDTH / 2:
				continue

			if _is_next_to_barrier(tile_pos):
				risky_tiles.append(tile_pos)
			else:
				safe_tiles.append(tile_pos)

	safe_tiles.shuffle()
	risky_tiles.shuffle()
	if safe_tiles.is_empty() and risky_tiles.is_empty():
		fallback_tiles.shuffle()
		return fallback_tiles

	return safe_tiles + risky_tiles

func _construct_border(has_entrance: bool) -> void:
	for x in range(0, room_size.x):
		var ceiling_tile = Vector2i(x, 0)

		@warning_ignore("integer_division")
		if x < room_size.x/2 - OPENING_WIDTH/2 or x >= room_size.x/2 + OPENING_WIDTH/2:
			barrier_tiles.append(ceiling_tile)
			continue

		exit_tiles.append(ceiling_tile)

	# floor
	for x in range(0, room_size.x):
		var ceiling_tile = Vector2i(x, room_size.y - 1)

		@warning_ignore("integer_division")
		if x < room_size.x/2 - OPENING_WIDTH/2 or x >= room_size.x/2 + OPENING_WIDTH/2:
			barrier_tiles.append(ceiling_tile)
			continue

		if has_entrance:
			entrance_tiles.append(ceiling_tile)
			continue

		barrier_tiles.append(ceiling_tile)

	# walls
	for y in range(1, room_size.y-1):
		barrier_tiles.append(Vector2i(0, y))
		barrier_tiles.append(Vector2i(room_size.x - 1, y))

func _construct_obstacles(compartment_num: int) -> void:
	if compartment_num == 1:
		return

	match pattern:
		Pattern.ALTERNATING_PIPES:
			_construct_alternating_pipes(compartment_num)
		Pattern.CENTER_SHAFT:
			_construct_center_shaft_pipes(compartment_num)
		Pattern.DOUBLE_GAP_PIPES:
			_construct_double_gap_pipes(compartment_num)
		Pattern.OPEN_ARENA:
			_construct_open_arena(compartment_num)
		_:
			_construct_random_pipes(compartment_num)

func _choose_pattern(compartment_num: int, difficulty_level: int) -> int:
	if compartment_num <= 1 or difficulty_level <= 1:
		return Pattern.RANDOM_PIPES

	var options: Array[int] = [Pattern.RANDOM_PIPES, Pattern.CENTER_SHAFT]
	if difficulty_level >= 4:
		options.append(Pattern.ALTERNATING_PIPES)
	if difficulty_level >= 7:
		options.append(Pattern.DOUBLE_GAP_PIPES)
	if difficulty_level >= 10:
		options.append(Pattern.OPEN_ARENA)

	return options.pick_random()

func _construct_random_pipes(compartment_num: int) -> void:
	var pipe_num = compartment_num - 1
	@warning_ignore("integer_division")
	var compartment_width = (room_size.x - pipe_num*PIPE_THICKNESS - 2) / compartment_num

	for i in range(pipe_num):
		var x = 1 + compartment_width + i*(compartment_width + PIPE_THICKNESS)
		var gap_pos := randi_range(1, room_size.y - GAP_HEIGHT - 1)
		_add_pipe(x, [Vector2i(gap_pos, GAP_HEIGHT)])

func _construct_alternating_pipes(compartment_num: int) -> void:
	var pipe_num = compartment_num - 1
	@warning_ignore("integer_division")
	var compartment_width = (room_size.x - pipe_num*PIPE_THICKNESS - 2) / compartment_num
	var low_gap := room_size.y - GAP_HEIGHT - 1

	for i in range(pipe_num):
		var x = 1 + compartment_width + i*(compartment_width + PIPE_THICKNESS)
		var base_gap := 1 if i % 2 == 0 else low_gap
		var gap_pos := clampi(base_gap + randi_range(-1, 1), 1, low_gap)
		_add_pipe(x, [Vector2i(gap_pos, GAP_HEIGHT)])

func _construct_center_shaft_pipes(compartment_num: int) -> void:
	var pipe_num = compartment_num - 1
	@warning_ignore("integer_division")
	var compartment_width = (room_size.x - pipe_num*PIPE_THICKNESS - 2) / compartment_num
	var low_gap := room_size.y - GAP_HEIGHT - 1
	@warning_ignore("integer_division")
	var gap_pos := (room_size.y - GAP_HEIGHT) / 2

	for i in range(pipe_num):
		var x = 1 + compartment_width + i*(compartment_width + PIPE_THICKNESS)
		gap_pos = clampi(gap_pos + randi_range(-1, 1), 1, low_gap)
		_add_pipe(x, [Vector2i(gap_pos, GAP_HEIGHT)])

func _construct_double_gap_pipes(compartment_num: int) -> void:
	var pipe_num = compartment_num - 1
	@warning_ignore("integer_division")
	var compartment_width = (room_size.x - pipe_num*PIPE_THICKNESS - 2) / compartment_num
	var low_gap := maxi(1, room_size.y - DOUBLE_GAP_HEIGHT - 1)
	var middle_row := floori(room_size.y / 2.0)

	for i in range(pipe_num):
		var x = 1 + compartment_width + i*(compartment_width + PIPE_THICKNESS)
		var upper_gap := randi_range(1, maxi(1, middle_row - DOUBLE_GAP_HEIGHT))
		var lower_min := maxi(upper_gap + DOUBLE_GAP_HEIGHT + 1, middle_row)
		var lower_gap := randi_range(lower_min, low_gap)
		_add_pipe(x, [
			Vector2i(upper_gap, DOUBLE_GAP_HEIGHT),
			Vector2i(lower_gap, DOUBLE_GAP_HEIGHT),
		])

func _construct_open_arena(compartment_num: int) -> void:
	var pipe_num = compartment_num - 1
	@warning_ignore("integer_division")
	var compartment_width = (room_size.x - pipe_num*PIPE_THICKNESS - 2) / compartment_num

	for i in range(pipe_num):
		var x = 1 + compartment_width + i*(compartment_width + PIPE_THICKNESS)
		var upper_height := randi_range(1, 3)
		var lower_height := randi_range(1, 3)

		for y in range(1, 1 + upper_height):
			_add_barrier_tile(Vector2i(x, y))

		for y in range(room_size.y - 1 - lower_height, room_size.y - 1):
			_add_barrier_tile(Vector2i(x, y))

func _add_pipe(x: int, gaps: Array[Vector2i]) -> void:
	for y in range(1, room_size.y - 1):
		if _is_inside_any_gap(y, gaps):
			continue

		_add_barrier_tile(Vector2i(x, y))

func _is_inside_any_gap(y: int, gaps: Array[Vector2i]) -> bool:
	for gap in gaps:
		if y >= gap.x and y < gap.x + gap.y:
			return true

	return false

func _is_next_to_barrier(tile_pos: Vector2i) -> bool:
	var neighbors := [
		tile_pos + Vector2i.LEFT,
		tile_pos + Vector2i.RIGHT,
		tile_pos + Vector2i.UP,
		tile_pos + Vector2i.DOWN,
	]

	for neighbor in neighbors:
		if neighbor in barrier_tiles:
			return true

	return false

func _add_barrier_tile(tile_pos: Vector2i) -> void:
	if tile_pos not in barrier_tiles:
		barrier_tiles.append(tile_pos)
