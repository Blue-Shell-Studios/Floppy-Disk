extends Node

const MAIN_MENU_STAGE := "main_menu"
const GAME_STAGE := "game"

const STAGES := {
	"main_menu": preload("res://core/stages/main_menu.tscn"),
	"game": preload("res://core/main/game.tscn"),
}

var stage_root: Node
var current_stage: Node
var current_stage_name := ""

func set_stage_root(root: Node) -> void:
	stage_root = root

func change_stage(stage_name: String) -> void:
	if stage_root == null or not is_instance_valid(stage_root):
		push_error("Stage root is not set.")
		return
	
	if not STAGES.has(stage_name):
		push_error("Unknown stage: " + stage_name)
		return
	
	get_tree().paused = false
	
	if current_stage != null and is_instance_valid(current_stage):
		current_stage.queue_free()
		current_stage = null
	
	current_stage = STAGES[stage_name].instantiate()
	current_stage_name = stage_name
	stage_root.add_child(current_stage)

func quit_game() -> void:
	get_tree().quit()
