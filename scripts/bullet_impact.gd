class_name BulletImpact extends MeshInstance3D

const TIMEOUT = 0.40
var elapsed := 0.0
var originalScale: Vector3

func _ready() -> void:
	originalScale = scale

func _process(delta: float) -> void:
	elapsed += delta

	if elapsed >= TIMEOUT:
		queue_free()
	else:
		var smaller := -(elapsed / TIMEOUT) + 1
		scale = originalScale * smaller
