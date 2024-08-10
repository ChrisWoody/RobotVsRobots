extends Path3D

@export var enemyScene: PackedScene
@export var enemyDeath: PackedScene

@onready var pathFollower: PathFollow3D = $PathFollow3D
@onready var gameManager: GameManager = get_node("../GameManager")

signal enemy_destroyed(count: int)

var spawnTimeout := 2.0
var spawnElapsed := 0.0

var totalEnemiesDestroyed := 0
var currentEnemyCount := 0
const TOTAL_ENEMY_COUNT := 10

var playing := false

func _process(delta: float) -> void:
	if not playing:
		return

	spawnElapsed += delta

	if spawnElapsed >= spawnTimeout:
		spawnElapsed = 0.0
		if totalEnemiesDestroyed >= 100:
			if currentEnemyCount >= 40:
				return
		elif totalEnemiesDestroyed >= 50:
			if currentEnemyCount >= 30:
				return
		elif totalEnemiesDestroyed >= 30:
			if currentEnemyCount >= 20:
				return
		elif currentEnemyCount >= 10:
			return

		var enemyInstance: Enemy = enemyScene.instantiate()
		add_sibling(enemyInstance)
		pathFollower.progress_ratio = randf()
		enemyInstance.enemy_death.connect(on_enemy_death)
		gameManager.start_game.connect(enemyInstance._on_game_manager_start_game)
		gameManager.game_over.connect(enemyInstance._on_game_manager_game_over)
		enemyInstance.spawn(pathFollower.global_position, enemyDeath)
		currentEnemyCount += 1

func on_enemy_death() -> void:
	currentEnemyCount -= 1
	totalEnemiesDestroyed += 1
	if totalEnemiesDestroyed >= 50:
		spawnTimeout = 0.75
	elif totalEnemiesDestroyed >= 30:
		spawnTimeout = 1.25
	else:
		spawnTimeout = 2.0
	enemy_destroyed.emit(totalEnemiesDestroyed)

func _on_game_manager_start_game() -> void:
	currentEnemyCount = 0
	spawnElapsed = 0.0
	totalEnemiesDestroyed = 0
	spawnTimeout = 2.0
	playing = true

func _on_game_manager_game_over() -> void:
	playing = false
