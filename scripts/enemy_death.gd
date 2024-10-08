class_name EnemyDeath extends Node3D

const TIMEOUT := 3.0
const FADE_START := 2.5
const DEATH_INDICATOR_TIMEOUT := 0.1
var elapsed := 0.0

@onready var deathIndicactor: MeshInstance3D = $DeathIndicator

var fading := true

func _process(delta: float) -> void:
	if fading:
		elapsed += delta
		if elapsed >= TIMEOUT:
			queue_free()
		elif elapsed >= FADE_START:
			position += Vector3.DOWN * delta * 2.0
		elif elapsed >= DEATH_INDICATOR_TIMEOUT:
			deathIndicactor.visible = false

func _on_game_manager_start_game() -> void:
	queue_free()

func _on_game_manager_game_over() -> void:
	fading = false
	var rigidBodies := find_children("", "RigidBody3D")
	for item in rigidBodies:
		item.freeze = true