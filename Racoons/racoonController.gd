extends CharacterBody3D

enum Racoon_State {
	Patrol,
	Chase,
	Search
}

enum SearchDirection{
	NA,
	Left,
	Right
}


@onready var nav_agent= $NavigationAgent3D
@onready var raycast: RayCast3D = $RayCast3D #Raycast detects objects between raccoon and mouse
@onready var turn_timer: Timer = $TurnTimer #timer for raccoon to turn when searching
@onready var search_timer: Timer = $SearchTimer #timer to search (in case search is impossible so it gives up)
@onready var detection_light: SpotLight3D = $SpotLight3D
@onready var detection_collider: CollisionShape3D = $Area3D/CollisionShape3D


@export var SEARCH_TIME=5.0
@export var TURN_TIME=1.0
@export var SPEED=3.0
@export var FOV=160
@export var ROTATION_SPEED=2
@export  var patrol_points: Array[Node3D] #points to cycle through Patrol State takes in node 3d points

var current_state=Racoon_State.Patrol
var current_dir=SearchDirection.NA
var starting_position: Vector3
var last_known_position: Vector3 
var original_y_rotation: float
var in_view =false #player is inside fov
var player: RigidBody3D=null
var in_area = false # player is inside area 2d collider
var current_patrol_point=0


func _ready() -> void:
	#get original positions so raccoon can return to them
	starting_position=global_position
	original_y_rotation=rotation.y
	detection_light.spot_angle=(FOV/2)+10
	var cylinder_collider: CylinderShape3D =detection_collider.shape
	detection_light.spot_range=cylinder_collider.radius+1.5

func _physics_process(delta: float) -> void:
	if in_area and player:
		in_view=is_in_view(player)
	if in_view and player:
		raycast.target_position = to_local(player.global_position)
		raycast.force_raycast_update()
		if raycast.is_colliding() and raycast.get_collider() != player:
			#print("collided")
			in_view=false
		else:
			current_state=Racoon_State.Chase
	match current_state:
		Racoon_State.Chase:
			#first check if any walls exixt that may stop the chase
			detection_light.light_color =Color(1,0,0,1)
			raycast.target_position = to_local(player.global_position)
			raycast.force_raycast_update()
			if raycast.is_colliding() and raycast.get_collider() != player:
				#print("collided")
				in_view=false
			else:
				last_known_position=player.global_position
			
			if in_area and in_view:
				# if within fov and collision area: chase
				update_target_location(player.global_position)
				
			else:
				# otherwise move to search
				current_state=Racoon_State.Search
		Racoon_State.Search:
			detection_light.light_color =Color(1,0.5,0,1)
			search_timer.start(SEARCH_TIME) # timer incase search gets stuck
			update_target_location(last_known_position)
			if nav_agent.is_navigation_finished(): 
				
				if turn_timer.is_stopped():
					#print("Timer start") # look left and right for 1 second
					turn_timer.start(TURN_TIME)
			
			
			
		Racoon_State.Patrol:
			detection_light.light_color =Color(0.95,0.95,0,1)
			# iterates through patrol points and updates nav target accordingly
			if patrol_points.size()>0:
				
				update_target_location(patrol_points[current_patrol_point].global_position)
				if nav_agent.is_navigation_finished():
					current_patrol_point+=1
					if current_patrol_point==patrol_points.size():
						current_patrol_point=0
			else:
				update_target_location(starting_position)
	
	#movement code
	if nav_agent.is_navigation_finished(): 
		velocity=Vector3.ZERO
	else:
		#applies velocity along the direction of the normalized path
		var current_location= global_transform.origin
		var next_location= nav_agent.get_next_path_position()
		var new_velocity=(next_location-current_location).normalized() * SPEED
		velocity=velocity.move_toward(transform.basis.z.normalized()*SPEED, .25)
		if new_velocity.length() > 0.01:
			var target_rotation = atan2(new_velocity.x, new_velocity.z)
			rotation.y = lerp_angle(rotation.y, target_rotation, ROTATION_SPEED * delta)
		
		
		
	move_and_slide()


	
	


func update_target_location(target_location):
	nav_agent.target_position=target_location


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"): #change to group
		
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
	if body.is_in_group("Player"):
		
		in_area=false
		in_view=false
		
	
func _on_turn_timer_timeout() -> void:
	#print("end of timer")
	match current_dir:
		SearchDirection.NA:
			rotation.y += deg_to_rad(90)
			#print("Left")
			current_dir=SearchDirection.Left
			
		SearchDirection.Left:
			rotation.y += deg_to_rad(-180)
			#print("Right")
			current_dir=SearchDirection.Right
		SearchDirection.Right:
			
			current_dir=SearchDirection.NA
			
			current_state = Racoon_State.Patrol
			return


func _on_search_timer_timeout() -> void:
	current_dir=SearchDirection.NA
	current_state = Racoon_State.Patrol
