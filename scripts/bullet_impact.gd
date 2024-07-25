class_name BulletImpact extends MeshInstance3D

@onready var particles: CPUParticles3D = $Particles

const TIMEOUT = 0.4
const QUEUE_TIMEOUT = 0.8
var elapsed := 0.0
var originalScale: Vector3

func _ready() -> void:
	originalScale = scale

func _process(delta: float) -> void:
	elapsed += delta

	if elapsed >= QUEUE_TIMEOUT:
		queue_free()
	elif elapsed >= TIMEOUT:
		particles.emitting = false
	else:
		var smaller := -(elapsed / TIMEOUT) + 1
		scale = originalScale * smaller
