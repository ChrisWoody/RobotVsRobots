extends Path3D

@export var enemyScene: PackedScene
@onready var pathFollower: PathFollow3D = $PathFollow3D
@onready var gameManager: GameManager = get_node("../GameManager")

signal enemy_destroyed(count: int)

const SPAWN_TIMEOUT := 2.0
var spawnElapsed := 0.0

var totalEnemiesDestroyed := 0
var currentEnemyCount := 0
const TOTAL_ENEMY_COUNT := 10

var playing := false

func _process(delta: float) -> void:
	if not playing:
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
		gameManager.start_game.connect(enemyInstance._on_game_manager_start_game)
		gameManager.game_over.connect(enemyInstance._on_game_manager_game_over)
		enemyInstance.spawn(pathFollower.global_position)
		currentEnemyCount += 1

# is this being called more than it should? Might be a timing/concurrency issue?
func on_enemy_death() -> void:
	currentEnemyCount -= 1
	totalEnemiesDestroyed += 1
	enemy_destroyed.emit(totalEnemiesDestroyed)

func _on_game_manager_start_game() -> void:
	currentEnemyCount = 0
	spawnElapsed = 0.0
	totalEnemiesDestroyed = 0
	playing = true

func _on_game_manager_game_over() -> void:
	playing = false
