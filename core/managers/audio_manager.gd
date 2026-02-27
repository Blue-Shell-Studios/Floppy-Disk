extends Node2D

@onready var pickup_bits: AudioStreamPlayer2D = $PickupBits
@onready var player_died: AudioStreamPlayer2D = $PlayerDied

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.requested_sfx.connect(_play_sound)

func _play_sound(sound_name: String):
	match sound_name:
		"pickup_bits":
			pickup_bits.play()

func _on_game_game_over(cur_level: int) -> void:
	player_died.play()
