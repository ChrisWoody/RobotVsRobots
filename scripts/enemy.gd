extends RigidBody3D

@export var player_path: NodePath
@onready var player := get_node("../Player")

const ROTATE_TIMEOUT := 0.5
var rotateElapsed := 0.0

func _physics_process(delta: float) -> void:
	rotateElapsed += delta
	if rotateElapsed > ROTATE_TIMEOUT:
		rotateElapsed = 0.0
		look_at(player.global_position)

	var diff: Vector3 = player.global_position - global_position
	var norm := diff.normalized()
	
	global_position += norm * 3.0 * delta
