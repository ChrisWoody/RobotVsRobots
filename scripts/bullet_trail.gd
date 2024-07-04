class_name BulletTrail extends MeshInstance3D

const TIMEOUT = 0.25
var elapsed := 0.0
var originalScale: Vector3

func set_size(newScale: Vector3) -> void:
	originalScale = newScale
	scale = originalScale

func _process(delta: float) -> void:
	elapsed += delta

	if elapsed >= TIMEOUT:
		queue_free()
	else:
		var smaller := -(elapsed / TIMEOUT) + 1

		var newScale = originalScale * smaller
		newScale.z = scale.z
		scale = newScale
