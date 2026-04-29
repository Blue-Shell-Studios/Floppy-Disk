extends Control

@onready var play_button: Button = $Buttons/PlayButton
@onready var exit_button: Button = $Buttons/ExitButton

var buttons: Array[Button] = []
var selected_index := 0

func _ready() -> void:
	buttons = [play_button, exit_button]
	play_button.pressed.connect(_on_play_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	play_button.focus_entered.connect(_on_button_focused.bind(0))
	exit_button.focus_entered.connect(_on_button_focused.bind(1))

	_focus_button(0)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_UP, KEY_LEFT, KEY_W, KEY_A:
				_focus_button(selected_index - 1)
				accept_event()
			KEY_DOWN, KEY_RIGHT, KEY_S, KEY_D:
				_focus_button(selected_index + 1)
				accept_event()
			KEY_ENTER, KEY_KP_ENTER, KEY_SPACE:
				buttons[selected_index].pressed.emit()
				accept_event()
			KEY_ESCAPE:
				_on_exit_pressed()
				accept_event()

func _focus_button(index: int) -> void:
	selected_index = wrapi(index, 0, buttons.size())
	buttons[selected_index].grab_focus()

func _on_button_focused(index: int) -> void:
	selected_index = index

func _on_play_pressed() -> void:
	StageManager.change_stage(StageManager.GAME_STAGE)

func _on_exit_pressed() -> void:
	StageManager.quit_game()
