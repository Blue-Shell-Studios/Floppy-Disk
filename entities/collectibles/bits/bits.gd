extends Area2D

signal coin_pickup

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	$AnimatedSprite2D.frame = randi() % $AnimatedSprite2D.sprite_frames.get_frame_count("default")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_pickup()

func _pickup() -> void:
	$CollisionShape2D.set_deferred("disabled", true)
	SignalBus.requested_sfx.emit("pickup_bits")
	
	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "scale", scale * 3, 0.3)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	
	await tween.finished
	queue_free()
