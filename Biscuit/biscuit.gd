extends Area3D

func _ready():
	print("I'm a biscuit...")
	
func _on_body_entered(body):
	print(body.name)
	if body.is_in_group("Player"):
		body.eat_biscuit()
		queue_free()
