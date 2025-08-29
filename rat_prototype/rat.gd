extends RigidBody3D

var SPEED: float = 2.0
var JUMP_VELOCITY: float = 2.0

func _ready():
	print("I'm a rat")

func eat_biscuit():
	print("yum biscuit")
	SPEED *= 0.5
	scale *= Vector3(2, 2, 2)  # shrink by 20%

@export var speed := 10.0 # Adjust this value to control movement speed

func _physics_process(delta: float) -> void:
	var force_direction := Vector3.ZERO

	if Input.is_action_pressed("ui_up"):
		force_direction -= transform.basis.z # Forward relative to the body's orientation
	if Input.is_action_pressed("ui_down"):
		force_direction += transform.basis.z # Backward
	if Input.is_action_pressed("ui_left"):
		force_direction -= transform.basis.x # Left
	if Input.is_action_pressed("ui_right"):
		force_direction += transform.basis.x # Right

	# Normalize the direction to ensure consistent speed when moving diagonally
	if force_direction.length() > 0:
		force_direction = force_direction.normalized()

	# Apply the force
	apply_central_force(force_direction * speed)
