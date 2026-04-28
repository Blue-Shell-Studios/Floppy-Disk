extends Node

@onready var stage_root: Node = $StageRoot

func _ready() -> void:
	StageManager.set_stage_root(stage_root)
	StageManager.change_stage(StageManager.MAIN_MENU_STAGE)
