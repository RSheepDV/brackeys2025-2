extends RigidBody3D
class_name RatController

@onready var model = $model
@onready var collider = $CollisionShape3D

@export var base_speed := 7.0 # Adjust this value to control movement speed
@export var linear_damp_override := 2.0 # higher = stops faster
@export var speed_reduction_factor = 0.5
@export var size_increase_factor = 0.5

@onready var base_size = model.scale.x
@onready var base_collider_size = collider.shape.radius

@onready var speed = base_speed

var biscuits = 0

func _ready():
	linear_damp = linear_damp_override

func eat_biscuit():
	biscuits += 1
	speed = base_speed * pow(speed_reduction_factor, biscuits)
	collider.shape.radius = base_collider_size * pow(size_increase_factor, biscuits)
	
	model.scale = base_size * Vector3.ONE * pow(size_increase_factor, biscuits)

func remove_biscuits():
	var output = biscuits
	
	biscuits = 0
	speed = base_speed * pow(speed_reduction_factor, biscuits)
	collider.shape.radius = base_collider_size * pow(size_increase_factor, biscuits)
	model.scale = base_size * Vector3.ONE * pow(size_increase_factor, biscuits)
	
	return output

func _physics_process(delta: float) -> void:
	model.position.x = position.x
	model.position.z = position.z
	model.position.y = position.y - base_size * pow(size_increase_factor, biscuits) + 0.2
	
	model.rotation = rotation
	
	var direction = Input.get_vector("move_left", "move_right", "move_down", "move_up")
	var force_direction = Vector3(direction.x, 0, -direction.y)

	# Apply the force
	apply_central_force(force_direction * speed)
