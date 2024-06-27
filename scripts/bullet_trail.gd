extends MeshInstance3D

const TIMEOUT = 0.25
var elapsed := 0.0

func _process(delta: float) -> void:
	elapsed += delta

	if elapsed >= TIMEOUT:
		queue_free()
	else:
		var smaller := -(elapsed / TIMEOUT) + 1

		var newScale = Vector3.ONE * smaller
		newScale.z = scale.z
		scale = newScale
		#mesh.size = Vector3(0.05, 0.05, 20) * scale
