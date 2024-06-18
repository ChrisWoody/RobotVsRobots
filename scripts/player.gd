extends CharacterBody3D

const SPEED = 15.0
const MOVE_ANGLE = 0.707107

func _physics_process(delta: float) -> void:

	var dir := Vector3.ZERO
	if Input.is_action_pressed("move_left"):
		dir += Vector3(-MOVE_ANGLE, 0, MOVE_ANGLE)
	if Input.is_action_pressed("move_right"):
		dir += Vector3(MOVE_ANGLE, 0, -MOVE_ANGLE)
	if Input.is_action_pressed("move_up"):
		dir += Vector3(-MOVE_ANGLE, 0, -MOVE_ANGLE)
	if Input.is_action_pressed("move_down"):
		dir += Vector3(MOVE_ANGLE, 0, MOVE_ANGLE)

	if dir != Vector3.ZERO:
		velocity.x = dir.x * SPEED
		velocity.z = dir.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
