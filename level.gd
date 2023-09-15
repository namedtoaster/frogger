extends Node

@export var time_limit: float = 4.0
@export var last_step = 100
const OBST_SPEED = 215
const OBST_ANIM_SPEED = 3
const OBST_H_S = 127
const OBST_V_S = 215
var game_over = false
var step = 0
var end = false
var prev_step = -1
var last_dir = ""
var prize = false
var treat_slow = false
var orig_dog_pos = Vector2(0, 0)
var jumping = false
@export var jump_amount = 4
var start_jump_pos = 0

signal up_pressed
signal down_pressed
# probably connect a game_over signal to the sub nodes?
signal level_complete

var obs_generator = preload("res://obstacle_generator.gd").new()
@onready var obs = preload("res://obstacle.tscn")

func get_timer_text(val):
	var tmp = str(val)
	return tmp.substr(0,4)
	
# builtin functions
func _ready():
	# Connect the signal for obstacle collision detection
	$CharacterBody2D.connect("hit_obstacle", _on_Obstacle_hit)
	# connect the signal for prize detection
	$CharacterBody2D.connect("prize_collected", _on_Prize_collected)
	# connect the signal for jymp detection
	$CharacterBody2D.connect("jump_collected", _on_Jump_collected)
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
		
	create_obstacles(false)
	
func _process(_delta):
	# update timer text
	$TimerText.text = get_timer_text($Timer.time_left)
	
	# check if the player got a prize
	check_prize()
	
	# if the player jumps, move everybody else
	jump()

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
		if event.is_action_pressed("test_jump"):
			start_jump_pos = $Obstacles/Obstacle.position.y
			jumping = true
# callbacks
func _on_Obstacle_hit():
	if not jumping:
		set_game_over()
		
func _on_Prize_collected(name):
	if not jumping:
		prize = true
		remove_prize(name)
		
func _on_Jump_collected(name):
	if not jumping:
		prev_step = step
		step += jump_amount
		start_jump_pos = $Obstacles.get_children()[0].position.y
			
		jumping = true
		remove_jump(name)
		
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
	# TODO: add text to screen
	print("level complete")
	$EndTimer.start()
	
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
	
func _on_end_timer_timeout():
	emit_signal("level_complete")
	
# utility functions
func create_obstacles(print_grid):
	var obs_grid = obs_generator.generate_obstacles_array(last_step)
	for i in range(last_step):
		if print_grid:
			print(str(obs_grid[i][0]) + ' ' + str(obs_grid[i][1]) + ' ' + str(obs_grid[i][2]))
		for j in range(3):
			if obs_grid[i][j] == 1:
				var obs_inst = obs.instantiate()
				obs_inst.name = "Obstacle" + str(i + j)
				obs_inst.position.y -= i * OBST_V_S
				obs_inst.position.x += j * OBST_H_S
				$Obstacles.add_child(obs_inst)
		

#	var test = obs.instantiate()
#	test.position.y += OBST_V_S
#	test.position.x += OBST_H_S
#	$Obstacles.add_child(test)
#
#	var test2 = obs.instantiate()
#	test2.position.x += OBST_H_S
#	test2.position.y += OBST_V_S * 2
#	$Obstacles.add_child(test2)
	
func jump():
	if jumping:
		for obstacle in $Obstacles.get_children():
			obstacle.position.y += OBST_ANIM_SPEED
		
		for prize in $Prizes.get_children():
			prize.position.y += OBST_ANIM_SPEED
			
		var obs_mv_amt = $Obstacles.get_children()[0].position.y
		if obs_mv_amt >= (start_jump_pos + (jump_amount * OBST_SPEED)):
			jumping = false
		
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
				
			for jump in $Jumps.get_children():
				jump.position.y += OBST_SPEED * dir
			
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
	# TODO: if you "jump" to the end using a token and hit the last step, this won't work
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
			
func remove_jump(name):
	for jump in $Jumps.get_children():
		if jump.name == name:
			jump.queue_free()
