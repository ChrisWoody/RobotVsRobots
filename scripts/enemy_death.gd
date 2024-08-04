class_name EnemyDeath extends Node3D

const TIMEOUT := 1.0
var elapsed := 0.0

var fade := true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if fade:
		elapsed += delta
		if elapsed >= TIMEOUT:
			queue_free()

func _on_game_manager_start_game() -> void:
	queue_free()

func _on_game_manager_game_over() -> void:
	fade = false
	# todo, on gameover, freeze the physics of the objects, OR do it at the game manager levle