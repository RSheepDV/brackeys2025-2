extends Node3D

@onready var mouse: CharacterBody3D = $Mouse

func _physics_process(delta: float) -> void:
	get_tree().call_group("Enemies","update_target_location",mouse.global_transform.origin)
