extends Node2D

signal game_started
signal game_over(cur_level: int)

var running := false
var is_game_over := false
var level : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.player_died.connect(_game_over)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not running and Input.is_action_just_pressed("ui_accept"):
		running = true
		game_started.emit()
	
	if is_game_over and Input.is_action_just_pressed("ui_accept"):
		get_tree().reload_current_scene()

func _game_over():
	is_game_over = true
	game_over.emit(level)

func _on_room_manager_level_cleared(new_level: int) -> void:
	level = new_level
