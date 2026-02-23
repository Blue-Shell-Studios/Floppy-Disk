extends Area2D

signal player_lose

const SPEED = 100

@onready var floppy_disk: CharacterBody2D = $"../FloppyDisk"

func _process(delta: float) -> void:
	if floppy_disk == null:
		return
	var direction = (floppy_disk.position - position).normalized()
	position += direction * SPEED * delta


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_lose.emit()
