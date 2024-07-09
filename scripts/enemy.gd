class_name Enemy extends RigidBody3D

@export var player_path: NodePath
@onready var player := get_node("../Player")

const ROTATE_TIMEOUT := 0.5
var rotateElapsed := 0.0

var speed := 3.0
var health := 10

func _ready() -> void:
	speed = 3.0 + (randf() * 2.0)

func _physics_process(delta: float) -> void:
	rotateElapsed += delta
	if rotateElapsed > ROTATE_TIMEOUT:
		rotateElapsed = 0.0
		look_at(player.global_position)

	global_position += -basis.z.normalized() * speed * delta

func hit() -> void:
	health -= 1
	if health <= 0:
		queue_free()