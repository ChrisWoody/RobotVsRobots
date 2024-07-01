extends CharacterBody3D

const SPEED := 10.0
const MOVE_ANGLE := 0.707107

const FIRE_TIMEOUT := 0.15
var fireElapsed := 0.0

const GUN_LIGHT_TIMEOUT := 0.20
var gunLightElapsed := 0.0

@onready var base: MeshInstance3D = $Base
@onready var body: MeshInstance3D = $Body

@export var bulletTrail: PackedScene

@onready var leftArmRayCast: RayCast3D = $Body/LeftArmRayCast
@onready var rightArmRayCast: RayCast3D = $Body/RightArmRayCast
@onready var gunFlash: OmniLight3D = $Body/GunFlash

func _physics_process(delta: float) -> void:

	var baseRotation := 0.0
	var bodyRotation := 0.0

	var dir := Vector3.ZERO
	if Input.is_action_pressed("move_left"):
		dir = Vector3(-MOVE_ANGLE, 0, MOVE_ANGLE)
		baseRotation = -45.0
	if Input.is_action_pressed("move_right"):
		dir = Vector3(MOVE_ANGLE, 0, -MOVE_ANGLE)
		baseRotation = 135.0
	if Input.is_action_pressed("move_up"):
		dir = Vector3(-MOVE_ANGLE, 0, -MOVE_ANGLE)
		baseRotation = -135.0
	if Input.is_action_pressed("move_down"):
		dir = Vector3(MOVE_ANGLE, 0, MOVE_ANGLE)
		baseRotation = 45.0

	if Input.is_action_pressed("move_left") and Input.is_action_pressed("move_up"):
		dir = Vector3(-1, 0, 0)
		baseRotation = -90.0
	if Input.is_action_pressed("move_left") and Input.is_action_pressed("move_down"):
		dir = Vector3(0, 0, 1)
		baseRotation = 0.0
	if Input.is_action_pressed("move_right") and Input.is_action_pressed("move_up"):
		dir = Vector3(0, 0, -1)
		baseRotation = 180.0
	if Input.is_action_pressed("move_right") and Input.is_action_pressed("move_down"):
		dir = Vector3(1, 0, 0)
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
		shoot(delta)

	if dir != Vector3.ZERO:
		velocity.x = dir.x * SPEED
		velocity.z = dir.z * SPEED
		base.rotation_degrees = Vector3(0.0, baseRotation, 0.0)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	gunLightElapsed -= delta

	if gunLightElapsed < 0.0:
		gunLightElapsed = 0.0
	gunFlash.light_energy = gunLightElapsed / GUN_LIGHT_TIMEOUT

	move_and_slide()

func shoot(delta: float):
	fireElapsed += delta

	if fireElapsed >= FIRE_TIMEOUT:
		gunLightElapsed = GUN_LIGHT_TIMEOUT
		fireElapsed = 0.0

		var leftSize := 9
		var leftHit = leftArmRayCast.get_collider()
		if leftHit:
			leftSize = 4
		# var rightHit = rightArmRayCast.get_collider()

		var leftBulletTrail: MeshInstance3D = bulletTrail.instantiate()
		add_sibling(leftBulletTrail)
		leftBulletTrail.global_rotation = leftArmRayCast.global_rotation
		leftBulletTrail.global_position = leftArmRayCast.global_position + (leftBulletTrail.basis.z.normalized() * leftSize)

		var rightBulletTrail: MeshInstance3D = bulletTrail.instantiate()
		add_sibling(rightBulletTrail)
		rightBulletTrail.global_rotation = rightArmRayCast.global_rotation
		rightBulletTrail.global_position = rightArmRayCast.global_position + (rightBulletTrail.basis.z.normalized() * 9)