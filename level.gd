extends Node

@export var time_limit: float = 4.0
@export var last_step = 10
const OBST_SPEED = 215
var game_over = false
var step = 0
var end = false
var prev_step = -1
var last_dir = ""
var prize = false
var treat_slow = false
var orig_dog_pos = Vector2(0, 0)

signal up_pressed
signal down_pressed
# probably connect a game_over signal to the sub nodes?
signal end_game

func get_timer_text(val):
	var tmp = str(val)
	return tmp.substr(0,4)
	
# builtin functions
func _ready():
	# Connect the signal for obstacle collision detection
	$CharacterBody2D.connect("hit_obstacle", _on_Obstacle_hit)
	# connect the signal for prize detection
	$CharacterBody2D.connect("prize_collected", _on_Prize_collected)
	# connect the signal for throwing the treat
	$CharacterBody2D.connect("throw_treat", _on_Treat_thrown)
	
	# Connect the signal for the timer
	$Timer.connect("timeout", _on_Timer_timeout)
	# connet the signal for when the player has reached the end
	$CharacterBody2D.connect("reached_end", _on_Player_reached_end)
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
	# set the starting position for the dog
	orig_dog_pos = $Dog.position
	
	# turn off treat animation until ready
	set_treat(false)
	
	# set the farthest point to where the player is right now
	#farthest = $CharacterBody2D.velocity.y
	
func _process(_delta):
	# update timer text
	$TimerText.text = get_timer_text($Timer.time_left)
	
	# check if the player got a prize
	check_prize()

func _input(event):
	# probably don't need to create a signal here since it's the same file, but maybe move elsewhere later
	if not game_over:
		if event.is_action_pressed("up"):
			last_dir = "up"
			prev_step = step
			if step <= last_step:
				step += 1
				
			$Timer.start()
			emit_signal("up_pressed")
		elif event.is_action_pressed("down") and step != 0:
			last_dir = "down"
			prev_step = step
			step -= 1
			update_end()
			
			if prev_step != last_step + 1:
				emit_signal("down_pressed")
			

# callbacks
func _on_Obstacle_hit():
	set_game_over()
		
func _on_Prize_collected(name):
	prize = true
	remove_prize(name)
		
func _on_Up_pressed():
	if not treat_slow:
		move_dog(-1)
	update_item_positions(1)
	
func _on_Down_pressed():
	update_item_positions(-1)

func _on_Timer_timeout():
	$Timer.stop()
	set_game_over()
	
func _on_Player_reached_end():
	set_game_over()
	
func _on_Treat_thrown():
	if prize:
		set_treat(true)
		$Treat/AnimationPlayer.play("throw_treat")
		prize = false
	
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "throw_treat":
		$Treat.visible = false
		
func _on_area_2d_area_entered(area):
	var name = area.get_parent().name
	if name == "Treat":
		treat_slow = true
		$Dog/AnimationPlayer.stop()
		$Dog/Timer.start()
		set_dog(false)
		
func _on_timer_timeout():
	if not game_over:
		treat_slow = false
		$Dog.position = orig_dog_pos
		set_dog(true)
	
	
# utility functions
func set_game_over():
	game_over = true
	
	# set game over for character
	$CharacterBody2D.game_over = true
	
	# display game over
	$GameOver.visible = true
	
	# stop timer
	$Timer.stop()
	
	# stop animation if it's playing
	# this just resets the animation, i would prefer to pause it. but this works for now
	$Dog/AnimationPlayer.stop(true)
	
func update_item_positions(dir):
	# only move if it's not game over
	if not game_over:
		# only move if we're not on the last step or we're moving down
		if not end or dir == -1:
			for obstacle in $Obstacles.get_children():
				obstacle.position.y += OBST_SPEED * dir
				
			for prize in $Prizes.get_children():
				prize.position.y += OBST_SPEED * dir
			
	update_end()

func move_dog(dir):
	$Dog/AnimationPlayer.stop()
	$Dog/AnimationPlayer.play("creep")
	
func set_dog(show):
	$Dog.visible = show
	$Dog/Area2D.set_collision_layer_value(1, show)
	$Dog/Area2D.set_collision_mask_value(1, show)

func update_end():
	end = (step == last_step or step == last_step + 1)
	$CharacterBody2D.end = ((prev_step == last_step) and last_dir == "up") or (prev_step == last_step + 1)

func check_prize():
	$GUI/MarginContainer/VBoxContainer/HBoxContainer/Treat.visible = prize
	
func set_treat(show):
	$Treat.visible = show
	$Treat/Area2D.set_collision_layer_value(16, show)
		

func remove_prize(name):
	for prize in $Prizes.get_children():
		if prize.name == name:
			prize.queue_free()
