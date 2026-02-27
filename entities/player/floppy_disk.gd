extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -600.0

@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var is_going_right :=  true
var running := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	
	position = GameConfig.SCREEN_SIZE/2
	visible = false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if ray_cast_left.is_colliding():
		is_going_right = true
	elif ray_cast_right.is_colliding():
		is_going_right = false
		
	animated_sprite_2d.flip_h = not is_going_right

	if Input.is_action_just_pressed("ui_accept"):
		$FlappingSound.play()
		velocity.y = JUMP_VELOCITY

	velocity.x = (1 if is_going_right else -1) * SPEED
	animated_sprite_2d.rotation = (1 if is_going_right else -1) * (velocity.y / 1200) * (PI / 2.0)

	move_and_slide()

func _on_game_game_started() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	
	visible = true
	running = true

func _on_game_game_over(cur_level: int) -> void:
	queue_free()
