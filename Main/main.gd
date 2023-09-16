extends Control

@export_file var LVL_PATH

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_level_complete():
	print("hi")


func _on_button_pressed():
	get_tree().change_scene_to_file(LVL_PATH)
