extends CanvasLayer

const PADDING = 40

@onready var score: Label = $Details/Score
@onready var game_over_screen: Control = $GameOverScreen
@onready var game_over: Label = $GameOverScreen/GameOver
@onready var level_achieved: Label = $GameOverScreen/LevelAchieved
@onready var start_screen: Control = $StartScreen
@onready var title_card: TextureRect = $StartScreen/TitleCard
@onready var start_prompt: Label = $StartScreen/StartPrompt


var bounce_distance: float = 20.0
var duration: float = 1.5

func _ready() -> void:
	title_card.position = (GameConfig.SCREEN_SIZE - title_card.size)/2
	title_card.position.y = GameConfig.SCREEN_SIZE.y/6
	
	start_prompt.position = (GameConfig.SCREEN_SIZE - start_prompt.size)/2
	start_prompt.position.y = title_card.position.y + title_card.size.y + PADDING
	
	_start_bounce()

func _start_bounce() -> void:
	var tween = create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(title_card, "position:y", title_card.position.y - bounce_distance, duration)
	tween.tween_property(title_card, "position:y", title_card.position.y, duration)

func _on_room_manager_level_cleared(new_level: int) -> void:
	score.text = "Level No.: " + str(new_level)


func _on_game_game_started() -> void:
	start_screen.visible = false
	score.visible = true


func _on_game_game_over(cur_level: int) -> void:
	level_achieved.text = "You have reached level " + str(cur_level) + "!"
	
	score.visible = false
	game_over_screen.visible = true
	
	
