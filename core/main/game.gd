extends Node2D

signal game_started
signal game_over(cur_level: int)

var running := false
var is_game_over := false
var level : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.player_died.connect(_game_over)
	call_deferred("_start_game")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_game_over:
		return

	if Input.is_action_just_pressed("ui_accept"):
		StageManager.change_stage(StageManager.GAME_STAGE)
	elif Input.is_action_just_pressed("ui_cancel"):
		StageManager.change_stage(StageManager.MAIN_MENU_STAGE)

func _unhandled_input(event: InputEvent) -> void:
	if not is_game_over:
		return

	if event is InputEventScreenTouch and event.pressed:
		StageManager.change_stage(StageManager.GAME_STAGE)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		StageManager.change_stage(StageManager.GAME_STAGE)
		get_viewport().set_input_as_handled()

func _start_game() -> void:
	if running:
		return

	running = true
	game_started.emit()

func _game_over():
	if is_game_over:
		return

	is_game_over = true
	game_over.emit(level)

func _on_room_manager_level_cleared(new_level: int) -> void:
	level = new_level
