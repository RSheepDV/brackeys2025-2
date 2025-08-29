extends Node3D
class_name GameManager

@export var score_sc : float = 2.0
@export var score_expc : float = 2.0
@export var score_tpen : float = 2.0
@export var score_tmul : float = 2.0

var summation_score = 0
var biscuit_timer = 0

var final_timer = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	summation_score = 0
	biscuit_timer = 0
	final_timer = 0
	
	printScore()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	biscuit_timer += delta
	final_timer += delta
	
	if Input.is_action_just_pressed("Reset"):
		get_tree().reload_current_scene()

func depositBiscuits(amount: int):
	summation_score += (pow(amount, score_tpen) * score_sc) / pow(biscuit_timer, score_tpen)
	
	printScore()

func getFinalScore():
	return summation_score * pow(final_timer, score_tmul)

func printScore():
	print("Total Score", summation_score)
	print("Final Score", getFinalScore())
