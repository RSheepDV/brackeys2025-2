extends RigidBody3D

@export var linear_damp_override := 2.0 # higher = stops faster
@onready var model = $model
@export var speed_reduction_factor = 0.5
@export var size_increase_factor = 0.5

func _ready():
	linear_damp = linear_damp_override

func eat_biscuit():
	speed *= speed_reduction_factor
	model.scale *= Vector3.ONE * (size_increase_factor)

@export var speed := 3.0 # Adjust this value to control movement speed

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("move_left", "move_right", "move_down", "move_up")
	var force_direction = Vector3(direction.x, 0, -direction.y)

	# Apply the force
	apply_central_force(force_direction * speed)
