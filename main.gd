extends Control

const LVL_PATH = "res://level.tscn"
@onready var level = preload(LVL_PATH)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_level_complete():
	print("hi")


func _on_button_pressed():
	var level_inst = level.instantiate()
	add_child(level_inst)
	level_inst.connect("level_complete", _on_level_complete)
	get_tree().change_scene_to_file(LVL_PATH)
