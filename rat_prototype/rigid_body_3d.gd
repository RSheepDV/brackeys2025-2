extends RigidBody3D

@export var linear_damp_override := 2.0 # higher = stops faster

func _ready():
	print("I'm a rat")
	linear_damp = linear_damp_override

func eat_biscuit():
	print("yum biscuit")
	speed *= 0.5
	var child_mesh = get_node("MeshInstance3D")
	child_mesh.scale *= Vector3(1.5, 1.5, 1.5)

@export var speed := 3.0 # Adjust this value to control movement speed

func _physics_process(delta: float) -> void:
	var force_direction := Vector3.ZERO

	if Input.is_action_pressed("ui_up"):
		force_direction += Vector3.FORWARD
	if Input.is_action_pressed("ui_down"):
		force_direction += Vector3.BACK
	if Input.is_action_pressed("ui_left"):
		force_direction += Vector3.LEFT
	if Input.is_action_pressed("ui_right"):
		force_direction += Vector3.RIGHT

	# Normalize the direction to ensure consistent speed when moving diagonally
	if force_direction.length() > 0:
		force_direction = force_direction.normalized()

	# Apply the force
	apply_central_force(force_direction * speed)
