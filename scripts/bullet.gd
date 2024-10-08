class_name Bullet extends Node3D

const TIMEOUT := 1.0
var elapsed := 0.0
var maxDistance := Vector3.ZERO
var traveled := Vector3.ZERO

func fire(distance: Vector3):
	maxDistance = distance

func _process(delta: float) -> void:
	elapsed += delta
	if elapsed >= TIMEOUT:
		queue_free()
	else:
		var frameTravelled = basis.z * delta * 50.0
		traveled += frameTravelled
		position += frameTravelled
		if traveled.length() > maxDistance.length():
			queue_free()
		
