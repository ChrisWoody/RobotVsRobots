extends CharacterBody3D

const SPEED = 15.0
const MOVE_ANGLE = 0.707107

@onready var base: MeshInstance3D = $Base
@onready var body: MeshInstance3D = $Body

func _physics_process(delta: float) -> void:

	var baseRotation := 0.0
	var bodyRotation := 0.0

	var dir := Vector3.ZERO
	if Input.is_action_pressed("move_left"):
		dir += Vector3(-MOVE_ANGLE, 0, MOVE_ANGLE)
		baseRotation = -45.0
	if Input.is_action_pressed("move_right"):
		dir += Vector3(MOVE_ANGLE, 0, -MOVE_ANGLE)
		baseRotation = 135.0
	if Input.is_action_pressed("move_up"):
		dir += Vector3(-MOVE_ANGLE, 0, -MOVE_ANGLE)
		baseRotation = -135.0
	if Input.is_action_pressed("move_down"):
		dir += Vector3(MOVE_ANGLE, 0, MOVE_ANGLE)
		baseRotation = 45.0

	if Input.is_action_pressed("move_left") and Input.is_action_pressed("move_up"):
		baseRotation = -90.0
	if Input.is_action_pressed("move_left") and Input.is_action_pressed("move_down"):
		baseRotation = 0.0
	if Input.is_action_pressed("move_right") and Input.is_action_pressed("move_up"):
		baseRotation = 180.0
	if Input.is_action_pressed("move_right") and Input.is_action_pressed("move_down"):
		baseRotation = 90.0

	var aimed := false
	if Input.is_action_pressed("aim_left") or Input.is_action_pressed("aim_right") or Input.is_action_pressed("aim_up") or Input.is_action_pressed("aim_down"):
		aimed = true

	if Input.is_action_pressed("aim_left"):
		bodyRotation = -45.0
	if Input.is_action_pressed("aim_right"):
		bodyRotation = 135.0
	if Input.is_action_pressed("aim_up"):
		bodyRotation = -135.0
	if Input.is_action_pressed("aim_down"):
		bodyRotation = 45.0

	if Input.is_action_pressed("aim_left") and Input.is_action_pressed("aim_up"):
		bodyRotation = -90.0
	if Input.is_action_pressed("aim_left") and Input.is_action_pressed("aim_down"):
		bodyRotation = 0.0
	if Input.is_action_pressed("aim_right") and Input.is_action_pressed("aim_up"):
		bodyRotation = 180.0
	if Input.is_action_pressed("aim_right") and Input.is_action_pressed("aim_down"):
		bodyRotation = 90.0

	if aimed:
		body.rotation_degrees = Vector3(0.0, bodyRotation, 0.0)

	if dir != Vector3.ZERO:
		velocity.x = dir.x * SPEED
		velocity.z = dir.z * SPEED
		base.rotation_degrees = Vector3(0.0, baseRotation, 0.0)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
