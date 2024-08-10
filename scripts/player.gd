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
@export var bullet: PackedScene

@onready var leftArmRayCast: RayCast3D = $Body/LeftArmRayCast
@onready var rightArmRayCast: RayCast3D = $Body/RightArmRayCast

@onready var leftArmBulletCasings: CPUParticles3D = $Body/LeftArmBulletCasings
@onready var rightArmBulletCasings: CPUParticles3D = $Body/RightArmBulletCasings

@onready var leftArmBarrels: Node3D = $Body/LeftArmBarrels
@onready var rightArmBarrels: Node3D = $Body/RightArmBarrels

@onready var leftMuzzleFlare: MeshInstance3D = $Body/LeftMuzzleFlare
@onready var rightMuzzleFlare: MeshInstance3D = $Body/RightMuzzleFlare

@onready var audioStreamPlayer: AudioStreamPlayer = $AudioStreamPlayer

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
		var newBodyY := computeAndClampRotationY(bodyMesh.rotation_degrees.y, bodyRotation, delta, 240.0)
		bodyMesh.rotation_degrees = Vector3(0.0, newBodyY, 0.0)

		shoot(delta)
		leftArmBarrels.rotate(Vector3.BACK, -360 * delta)
		rightArmBarrels.rotate(Vector3.BACK, 360 * delta)
		leftArmBulletCasings.emitting = true
		rightArmBulletCasings.emitting = true

	if dir != Vector3.ZERO:
		velocity.x = dir.x * SPEED
		velocity.z = dir.z * SPEED
		var newBaseY := computeAndClampRotationY(base.rotation_degrees.y, baseRotation, delta, 400.0)
		base.rotation_degrees = Vector3(0.0, newBaseY, 0.0)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	gunLightElapsed -= delta

	if gunLightElapsed < 0.0:
		gunLightElapsed = 0.0

	move_and_slide()

func computeAndClampRotationY(currentY: float, inputY: float, delta: float, speed: float) -> float:
	var rotateDir := 1.0 if abs(currentY - inputY) < 180.0 else -1.0
	var newY := move_toward(currentY, inputY, delta * speed * rotateDir)
	if newY < -180.0:
		newY += 360.0
	elif newY > 180.0:
		newY -= 360.0
	return newY

func shoot(delta: float):
	fireElapsed += delta

	if fireElapsed >= FIRE_TIMEOUT:
		gunLightElapsed = GUN_LIGHT_TIMEOUT
		fireElapsed = 0.0

		#audioStreamPlayer.play()

		leftMuzzleFlare.visible = true
		rightMuzzleFlare.visible = true

		leftMuzzleFlare.scale = Vector3(1.0 - (0.50 * randf()), 2.0 - (0.50 * randf()), 1.0 - (0.50 * randf()))
		rightMuzzleFlare.scale = Vector3(1.0 - (0.50 * randf()), 2.0 - (0.50 * randf()), 1.0 - (0.50 * randf()))

		var leftBullet: Bullet = bullet.instantiate()

		if leftArmRayCast.is_colliding():
			var leftBulletImpact: BulletImpact = bulletImpact.instantiate()
			add_sibling(leftBulletImpact)
			leftBulletImpact.global_position = leftArmRayCast.get_collision_point()
			var dirPos := -leftBulletImpact.global_position.direction_to(leftArmRayCast.global_position)
			var newBasis := Basis.looking_at(dirPos);
			leftBulletImpact.basis = newBasis
			leftBullet.fire(leftArmRayCast.get_collision_point() - leftMuzzleFlare.global_position)

			var leftHitNode := leftArmRayCast.get_collider() as Enemy
			if leftHitNode and leftHitNode.has_method("hit"):
				leftHitNode.hit()
		else:
			leftBullet.fire(Vector3(50.0, 50.0, 50.0))

		add_sibling(leftBullet)
		leftBullet.global_position = leftMuzzleFlare.global_position
		leftBullet.global_rotation = bodyMesh.global_rotation

		var rightBullet: Bullet = bullet.instantiate()

		if rightArmRayCast.is_colliding():
			var rightBulletImpact: BulletImpact = bulletImpact.instantiate()
			add_sibling(rightBulletImpact)
			rightBulletImpact.global_position = rightArmRayCast.get_collision_point()
			var dirPos := -rightBulletImpact.global_position.direction_to(rightArmRayCast.global_position)
			var newBasis := Basis.looking_at(dirPos);
			rightBulletImpact.basis = newBasis
			rightBullet.fire(rightArmRayCast.get_collision_point() - rightMuzzleFlare.global_position)

			var rightHitNode := rightArmRayCast.get_collider() as Enemy
			if rightHitNode and rightHitNode.has_method("hit"):
				rightHitNode.hit()
		else:
			rightBullet.fire(Vector3(50.0, 50.0, 50.0))

		add_sibling(rightBullet)
		rightBullet.global_position = rightMuzzleFlare.global_position
		rightBullet.global_rotation = bodyMesh.global_rotation

func _on_game_manager_start_game() -> void:
	playing = true


func _on_game_manager_game_over() -> void:
	playing = false
	leftMuzzleFlare.visible = false
	rightMuzzleFlare.visible = false
	leftArmBulletCasings.emitting = false
	rightArmBulletCasings.emitting = false


func _on_hitbox_body_entered(body: Node3D) -> void:
	if body.has_method("hit"):
		player_hit.emit()
