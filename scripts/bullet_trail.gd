extends Node

var elapsed := 0.0

func _process(delta: float) -> void:
	elapsed += delta
	if elapsed > 0.25:
		queue_free()
