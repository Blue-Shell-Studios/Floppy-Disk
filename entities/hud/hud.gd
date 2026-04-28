extends CanvasLayer

@onready var details: MarginContainer = $Details
@onready var score: Label = $Details/Score
@onready var game_over_screen: Control = $GameOverScreen
@onready var game_over: Label = $GameOverScreen/GameOver
@onready var level_achieved: Label = $GameOverScreen/LevelAchieved

func _on_room_manager_level_cleared(new_level: int) -> void:
	score.text = "Level No.: " + str(new_level)


func _on_game_game_started() -> void:
	details.visible = true


func _on_game_game_over(cur_level: int) -> void:
	level_achieved.text = "You have reached level " + str(cur_level) + "!"
	
	details.visible = false
	game_over_screen.visible = true
	
	
