extends Node2D

const SPEED = 800

@onready var cooldown_timer: Timer = $CooldownTimer
@onready var dash_timer: Timer = $DashTimer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var floppy_disk: Node = get_tree().get_nodes_in_group("player")[0]
var direction : Vector2
var is_dashing := false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if floppy_disk == null:
		return

	if not is_dashing:
		return
	
	position += direction * SPEED * delta

func _on_cooldown_timer_timeout() -> void:
	direction = global_position.direction_to(floppy_disk.global_position)
	
	if direction.x != 0:
		sprite.flip_h = direction.x < 0
		
	sprite.play("dashing")
	is_dashing = true
	dash_timer.start()


func _on_dash_timer_timeout() -> void:
	sprite.play("idle")
	is_dashing = false
	cooldown_timer.start()
