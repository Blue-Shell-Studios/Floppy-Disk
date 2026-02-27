extends Node2D

const MOVEMENT_SPEED = 400

var movable_nodes := []
var move_offset : Vector2

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func _process(delta: float) -> void:
	_move_all_movable_components(delta)

func _move_all_movable_components(delta: float) -> void:
	if move_offset == null:
		return
		
	var step = move_offset.normalized() * MOVEMENT_SPEED * delta
	
	if step.length() > move_offset.length():
		step = move_offset
	
	for node in movable_nodes:
		if not node or not is_instance_valid(node):
			continue 
		node.position -= step
	
	move_offset -= step
	
	if move_offset.length() <= 0:
		move_offset = Vector2.ZERO
		get_tree().paused = false

func _on_room_manager_next_level_ready(_move_offset: Vector2) -> void:
	movable_nodes = get_tree().get_nodes_in_group("movable")
	move_offset = _move_offset
	get_tree().paused = true
