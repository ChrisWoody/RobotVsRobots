extends Path3D

@export var enemyScene: PackedScene
@onready var pathFollower: PathFollow3D = $PathFollow3D

const SPAWN_TIMEOUT := 2.0
var spawnElapsed := 0.0

func _process(delta: float) -> void:
	spawnElapsed += delta

	if spawnElapsed >= SPAWN_TIMEOUT:
		spawnElapsed = 0.0
		var enemyInstance: Enemy = enemyScene.instantiate()
		add_sibling(enemyInstance)
		pathFollower.progress_ratio = randf()
		enemyInstance.global_position = pathFollower.global_position
