extends Node2D

const SPEED = 100

@onready var floppy_disk: Node = get_tree().get_nodes_in_group("player")[0]

func _process(delta: float) -> void:
	if floppy_disk == null:
		return
	var direction = global_position.direction_to(floppy_disk.global_position)
	position += direction * SPEED * delta
