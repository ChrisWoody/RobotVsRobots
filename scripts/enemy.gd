class_name Enemy extends RigidBody3D

@export var player_path: NodePath
@onready var player := get_node("../Player")

signal enemy_death

const ROTATE_TIMEOUT := 0.5
var rotateElapsed := 0.0

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
		enemy_death.emit()
		queue_free()

func spawn(newPosition: Vector3) -> void:
	speed = 4.0 + (randf() * 2.0)
	global_position = newPosition
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