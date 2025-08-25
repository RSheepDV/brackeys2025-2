extends CharacterBody3D



@onready var nav_agent= $NavigationAgent3D
@onready var raycast: RayCast3D = $RayCast3D


@export var SPEED=3.0
@export var FOV=140
@export var ROTATION_SPEED=2

var starting_position: Vector3
var original_y_rotation: float
var in_view =false
var player: CharacterBody3D=null
var in_area = false

func _ready() -> void:
	starting_position=global_position
	original_y_rotation=rotation.y

func _physics_process(delta: float) -> void:
	if in_area and player:
		in_view=is_in_view(player)
	if in_view :
		raycast.target_position = to_local(player.global_position)
		raycast.force_raycast_update()
		
		if raycast.is_colliding() and raycast.get_collider() != player:
			in_view=false
			print("Raycast Collided")
			
		update_target_location(player.global_position)
		
	else:
		update_target_location(starting_position)
	if nav_agent.is_navigation_finished():
		
		velocity=Vector3.ZERO
		rotation.y = lerp_angle(rotation.y, original_y_rotation, ROTATION_SPEED * delta)
	else:
		var current_location= global_transform.origin
		var next_location= nav_agent.get_next_path_position()
		var new_velocity=(next_location-current_location).normalized() * SPEED
		
		velocity=velocity.move_toward(new_velocity, .25)
		
		if new_velocity.length() > 0.01:
			var target_rotation = atan2(new_velocity.x, new_velocity.z)
			rotation.y = lerp_angle(rotation.y, target_rotation, ROTATION_SPEED * delta)
	move_and_slide()


func update_target_location(target_location):
	nav_agent.target_position=target_location


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "mouse":
		print("entered")
		in_area=true
		player=body
		
		
			

func is_in_view(player):
	#direction of player body from racoon
	var direction =global_position.direction_to(player.global_position)
	#normalized location of player wrt to racoons face
	var facing = global_transform.basis.tdotz(direction)
	
	var fov =cos(deg_to_rad(FOV/2))
	if facing>fov:
		return true
	else:
		return false
		
		
func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.name == "mouse":
		print("exited")
		in_view=false
		player=null
	
