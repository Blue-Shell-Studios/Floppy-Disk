extends Node2D

signal player_exit

const SOURCE_ID := 0
const BARRIER_TILE := Vector2i(7,3)
const EXIT_TILE := Vector2i(1,2)

@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var exit_collision: CollisionShape2D = $Exit/CollisionShape2D

var data : RoomData

func setup(room_size: Vector2i, compartment_num: int, enemies: Array = [], has_entrance: bool = true) -> void:
	data = RoomData.new(room_size, compartment_num, enemies, has_entrance)
	
	_construct_tiles()

func _construct_tiles() -> void:
	for tile_pos in data.barrier_tiles:
		tile_map_layer.set_cell(tile_pos, SOURCE_ID, BARRIER_TILE)
	
	for tile_pos in data.exit_tiles:
		tile_map_layer.set_cell(tile_pos, SOURCE_ID, EXIT_TILE)

func summon_enemies():
	for enemy in data.enemies:
		var enemy_scene = enemy.instantiate()
		add_child(enemy_scene)

func open() -> void:
	exit_collision.disabled = false
	for tile_pos in data.exit_tiles:
		tile_map_layer.erase_cell(tile_pos)

func close() -> void:
	for tile_pos in data.entrance_tiles:
		tile_map_layer.set_cell(tile_pos, SOURCE_ID, BARRIER_TILE)

func _on_exit_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_exit.emit()
		queue_free()
