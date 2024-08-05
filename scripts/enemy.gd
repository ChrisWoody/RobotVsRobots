class_name Enemy extends RigidBody3D

@export var player_path: NodePath
@onready var player := get_node("../Player")
@onready var gameManager: GameManager = get_node("../GameManager")

signal enemy_death

const ROTATE_TIMEOUT := 0.5
var rotateElapsed := 0.0

var enemyDeath: PackedScene

var alive := false
var speed := 0.0

const ORIGINAL_HEALTH := 10
var health := ORIGINAL_HEALTH

# func _ready() -> void:
# 	reset_and_hide()

func _physics_process(delta: float) -> void:
	if not alive:
		return

	rotateElapsed += delta
	if rotateElapsed > ROTATE_TIMEOUT:
		rotateElapsed = 0.0
		look_at(player.global_position)

	global_position += -basis.z.normalized() * speed * delta

func hit() -> void:
	health -= 1
	if health <= 0 and alive:
		alive = false
		var enemyDeathInstance: Node3D = enemyDeath.instantiate()
		add_sibling(enemyDeathInstance)
		gameManager.start_game.connect(enemyDeathInstance._on_game_manager_start_game)
		gameManager.game_over.connect(enemyDeathInstance._on_game_manager_game_over)

		enemyDeathInstance.global_position = global_position
		enemyDeathInstance.global_rotation = global_rotation
		var rigidBodies := enemyDeathInstance.find_children("", "RigidBody3D")
		for box in rigidBodies:
			box.linear_velocity = -basis.z.normalized() * (7.0 + (randf() * 5))
		enemy_death.emit()
		queue_free()

func spawn(newPosition: Vector3, enemyDeathThing: PackedScene) -> void:
	speed = 4.0 + (randf() * 2.0)
	global_position = newPosition
	enemyDeath = enemyDeathThing
	visible = true
	sleeping = false
	alive = true

func _on_game_manager_start_game() -> void:
	queue_free()

func _on_game_manager_game_over() -> void:
	alive = false

# func reset_and_hide() -> void:
# 	health = ORIGINAL_HEALTH
# 	visible = false
# 	sleeping = true