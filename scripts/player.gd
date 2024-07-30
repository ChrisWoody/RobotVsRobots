extends CharacterBody3D

const SPEED := 10.0
const MOVE_ANGLE := 0.707107

const FIRE_TIMEOUT := 0.15
var fireElapsed := 0.0

const GUN_LIGHT_TIMEOUT := 0.10
var gunLightElapsed := 0.0

signal player_hit

@onready var base: MeshInstance3D = $Base
@onready var bodyMesh: MeshInstance3D = $Body

@export var bulletTrail: PackedScene
@export var bulletImpact: PackedScene

@onready var leftArmRayCast: RayCast3D = $Body/LeftArmRayCast
@onready var rightArmRayCast: RayCast3D = $Body/RightArmRayCast

@onready var leftArmBulletCasings: CPUParticles3D = $Body/LeftArmBulletCasings
@onready var rightArmBulletCasings: CPUParticles3D = $Body/RightArmBulletCasings

@onready var leftArmBarrels: Node3D = $Body/LeftArmBarrels
@onready var rightArmBarrels: Node3D = $Body/RightArmBarrels

@onready var leftMuzzleFlare: MeshInstance3D = $Body/LeftMuzzleFlare
@onready var rightMuzzleFlare: MeshInstance3D = $Body/RightMuzzleFlare

var playing := false

func _ready() -> void:
	leftMuzzleFlare.visible = false
	rightMuzzleFlare.visible = false

func _physics_process(delta: float) -> void:
	if not playing:
		return

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

	leftMuzzleFlare.visible = false
	rightMuzzleFlare.visible = false
	leftArmBulletCasings.emitting = false
	rightArmBulletCasings.emitting = false

	if aimed:
		bodyMesh.rotation_degrees = Vector3(0.0, bodyRotation, 0.0)
		shoot(delta)
		leftArmBarrels.rotate(Vector3.BACK, -360 * delta)
		rightArmBarrels.rotate(Vector3.BACK, 360 * delta)
		leftArmBulletCasings.emitting = true
		rightArmBulletCasings.emitting = true

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

	move_and_slide()

func shoot(delta: float):
	fireElapsed += delta

	if fireElapsed >= FIRE_TIMEOUT:
		gunLightElapsed = GUN_LIGHT_TIMEOUT
		fireElapsed = 0.0

		leftMuzzleFlare.visible = true
		rightMuzzleFlare.visible = true

		leftMuzzleFlare.scale = Vector3(1.0 - (0.50 * randf()), 2.0 - (0.50 * randf()), 1.0 - (0.50 * randf()))
		rightMuzzleFlare.scale = Vector3(1.0 - (0.50 * randf()), 2.0 - (0.50 * randf()), 1.0 - (0.50 * randf()))

		if leftArmRayCast.is_colliding():
			var leftBulletImpact: BulletImpact = bulletImpact.instantiate()
			add_sibling(leftBulletImpact)
			leftBulletImpact.global_position = leftArmRayCast.get_collision_point()
			leftBulletImpact.global_rotation = Vector3(randf() * 180, randf() * 180, randf() * 180)

			var leftHitNode := leftArmRayCast.get_collider() as Enemy
			if leftHitNode and leftHitNode.has_method("hit"):
				leftHitNode.hit()

		if rightArmRayCast.is_colliding():
			var rightBulletImpact: BulletImpact = bulletImpact.instantiate()
			add_sibling(rightBulletImpact)
			rightBulletImpact.global_position = rightArmRayCast.get_collision_point()
			rightBulletImpact.global_rotation = Vector3(randf() * 180, randf() * 180, randf() * 180)

			var rightHitNode := rightArmRayCast.get_collider() as Enemy
			if rightHitNode and rightHitNode.has_method("hit"):
				rightHitNode.hit()

func _on_game_manager_start_game() -> void:
	playing = true


func _on_game_manager_game_over() -> void:
	playing = false


func _on_hitbox_body_entered(body: Node3D) -> void:
	if body.has_method("hit"):
		player_hit.emit()
