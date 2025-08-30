extends Control
@onready var Settings: Panel = $ColorRect/Panel
@onready var MainmenuPanel: VBoxContainer = $ColorRect/Page_Center/VBoxContainer

func _ready() -> void:
	%Play.pressed.connect(play)
	MainmenuPanel.visible=true
	Settings.visible=false
func play():
	get_tree().change_scene_to_file("res://LevelPrototypes/prototype1.tscn")
	


func _on_settings_pressed() -> void:
	MainmenuPanel.visible=false
	Settings.visible=true
	
	pass # Replace with function body.


func _on_back_pressed() -> void:
	_ready()# Replace with function body.
