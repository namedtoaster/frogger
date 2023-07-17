extends Node

@export var time_limit: float = 4.0
const OBST_SPEED = 215
var game_over = false
var farthest = 0

signal up_pressed
signal down_pressed
# probably connect a game_over signal to the sub nodes?
signal end_game

func get_timer_text(val):
	var tmp = str(val)
	return tmp.substr(0,4)
	
# builtin functions
func _ready():
	# Connect the signal for collision detection
	connect_obstacle_collision()
	# Connect the signal for the timer
	$Timer.connect("timeout", _on_Timer_timeout)
	# Connect the signal for when the player moves up
	self.connect("up_pressed", _on_Up_pressed)
	self.connect("down_pressed", _on_Down_pressed)
	
	# turn off game over text
	$GameOver.visible = false
	
	# set timer amount
	$Timer.wait_time = time_limit
	$Timer.start()
	# set timer text node to timer seconds
	$TimerText.text = get_timer_text($Timer.time_left)
	
	# animate dog
	$Dog/AnimationPlayer.play("creep")
	
	# set the farthest point to where the player is right now
	farthest = $CharacterBody2D.velocity.y
	
func _process(_delta):
	print($CharacterBody2D.velocity.y)
	print(farthest)
	# update timer text
	$TimerText.text = get_timer_text($Timer.time_left)

func _input(event):
	# probably don't need to create a signal here since it's the same file, but maybe move elsewhere later
	if not game_over:
		if event.is_action_pressed("up"):
			$Timer.start()
			emit_signal("up_pressed")
		elif event.is_action_pressed("down"):
			emit_signal("down_pressed")
			

# callbacks
func _on_Obstacle_body_entered(body):
	if body.name == "CharacterBody2D":
		# Collision occurred between Character2 and Character1
		print("Collision detected between Character2 and Character1")
		
		set_game_over()
		
func _on_Up_pressed():
	move_dog(-1)
	update_obstacle_positions(1)
	
func _on_Down_pressed():
	update_obstacle_positions(-1)

func _on_Timer_timeout():
	$Timer.stop()
	set_game_over()
	
	
# utility functions
func set_game_over():
	game_over = true
	
	# set game over for character
	$CharacterBody2D.game_over = true
	
	# display game over
	$GameOver.visible = true
	
	# stop timer
	$Timer.stop()
	
func connect_obstacle_collision():
	for obstacle in $Obstacles.get_children():
		var area2d = obstacle.get_node("Area2D")
		area2d.connect("body_entered", _on_Obstacle_body_entered)
#		$Obstacles/Obstacle/Area2D.connect("body_entered", _on_Obstacle_body_entered)
	
func update_obstacle_positions(dir):
	if not game_over:
		for obstacle in $Obstacles.get_children():
			obstacle.position.y += OBST_SPEED * dir

func move_dog(dir):
	$Dog/AnimationPlayer.stop()
	$Dog/AnimationPlayer.play("creep")
		
	$Dog/Sprite2D.position.y += dir * OBST_SPEED
