extends Path3D

@export var enemyScene: PackedScene
@onready var pathFollower: PathFollow3D = $PathFollow3D
@onready var gameManager: GameManager = get_node("../GameManager")

const SPAWN_TIMEOUT := 2.0
var spawnElapsed := 0.0

var currentEnemyCount := 0
const TOTAL_ENEMY_COUNT := 10

var playing := false

func _process(delta: float) -> void:
	if !playing:
		return

	spawnElapsed += delta

	if spawnElapsed >= SPAWN_TIMEOUT:
		spawnElapsed = 0.0
		if currentEnemyCount >= TOTAL_ENEMY_COUNT:
			return

		var enemyInstance: Enemy = enemyScene.instantiate()
		add_sibling(enemyInstance)
		pathFollower.progress_ratio = randf()
		enemyInstance.enemy_death.connect(on_enemy_death)
		enemyInstance.spawn(pathFollower.global_position)
		currentEnemyCount += 1

func on_enemy_death() -> void:
	currentEnemyCount -= 1

func _on_game_manager_start_game() -> void:
	currentEnemyCount = 0
	spawnElapsed = 0.0
	playing = true
