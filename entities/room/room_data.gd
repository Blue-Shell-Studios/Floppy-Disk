class_name RoomData extends RefCounted

const PIPE_THICKNESS = 1
const OPENING_WIDTH = 4
const GAP_HEIGHT = 4

var room_size : Vector2i
var barrier_tiles : Array
var entrance_tiles : Array
var exit_tiles : Array

var enemies : Array

func _init(_room_size: Vector2i, compartment_num: int, _enemies: Array = [], has_entrance: bool = true) -> void:
	room_size = _room_size
	enemies = _enemies
	
	# ceiling
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
	
	# obstacle aka pipe
	if compartment_num == 1:
		return
	
	var pipe_num = compartment_num - 1
	@warning_ignore("integer_division")
	var compartment_width = (room_size.x - pipe_num*PIPE_THICKNESS - 2) / compartment_num
	for i in range(pipe_num):
		var x = 1 + compartment_width + i*(compartment_width + PIPE_THICKNESS)
		var gap_pos = randi_range(1, room_size.y - GAP_HEIGHT - 1)
		
		for y in range(1, gap_pos):
			barrier_tiles.append(Vector2i(x,y))
		
		for y in range(gap_pos+GAP_HEIGHT, room_size.y-1):
			barrier_tiles.append(Vector2i(x,y))
