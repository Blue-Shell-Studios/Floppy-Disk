extends CanvasLayer

const BINARY_FONT := preload("res://assets/fonts/PixelOperator8.ttf")
const ROW_SPACING := 46.0
const MIN_ROW_COUNT := 18
const MAX_ROW_COUNT := 28
const SPEED_MIN := 18.0
const SPEED_MAX := 46.0
const LINE_LENGTH := 96

var rows: Array[Label] = []
var speeds: Array[float] = []
var screen_size := Vector2.ZERO

@onready var shade: ColorRect = $Shade
@onready var row_container: Control = $Rows

func _ready() -> void:
	layer = -100
	_configure_fullscreen_control(shade)
	_configure_fullscreen_control(row_container)
	_rebuild_rows()

func _process(delta: float) -> void:
	var current_size := GameConfig.get_screen_size(self)
	if current_size != screen_size:
		_rebuild_rows()
		return

	for i in range(rows.size()):
		var row := rows[i]
		row.position.y += speeds[i] * delta
		row.position.x += sin(Time.get_ticks_msec() * 0.001 + i) * delta * 8.0

		if row.position.y > screen_size.y + ROW_SPACING:
			_reset_row(row, i, -ROW_SPACING)

func _rebuild_rows() -> void:
	screen_size = GameConfig.get_screen_size(self)
	shade.size = screen_size
	row_container.size = screen_size

	for row in rows:
		row.queue_free()

	rows.clear()
	speeds.clear()

	var row_count := clampi(ceili(screen_size.y / ROW_SPACING) + 4, MIN_ROW_COUNT, MAX_ROW_COUNT)
	for i in range(row_count):
		var row := Label.new()
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_theme_font_override("font", BINARY_FONT)
		row.add_theme_font_size_override("font_size", 18)
		row.modulate = _get_row_color(i)
		row.rotation = randf_range(-0.035, 0.035)
		row_container.add_child(row)

		rows.append(row)
		speeds.append(randf_range(SPEED_MIN, SPEED_MAX))
		_reset_row(row, i, i * ROW_SPACING - ROW_SPACING * 2.0)

func _reset_row(row: Label, index: int, y: float) -> void:
	row.text = _make_binary_line()
	row.position = Vector2(randf_range(-screen_size.x * 0.18, screen_size.x * 0.08), y)
	row.modulate = _get_row_color(index)
	speeds[index] = randf_range(SPEED_MIN, SPEED_MAX)

func _make_binary_line() -> String:
	var text := ""
	for i in range(LINE_LENGTH):
		text += "1" if randi() % 2 == 0 else "0"
		if i % 4 == 3:
			text += " "

	return text

func _get_row_color(index: int) -> Color:
	var alpha := randf_range(0.06, 0.16)
	if index % 5 == 0:
		alpha = randf_range(0.12, 0.24)

	return Color(0.18, 0.95, 0.78, alpha)

func _configure_fullscreen_control(control: Control) -> void:
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	control.set_anchors_preset(Control.PRESET_FULL_RECT)
