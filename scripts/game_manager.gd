class_name GameManager extends Node

signal start_game
signal game_over

var playingGame := false

func _process(_delta: float) -> void:
	if not playingGame and Input.is_key_pressed(KEY_SPACE):
		playingGame = true
		start_game.emit()
	if Input.is_key_pressed(KEY_R):
		playingGame = false
		game_over.emit()

func _on_player_player_hit() -> void:
	playingGame = false
	game_over.emit()
