extends Node2D

signal reached_end
signal hit_obstacle
signal prize_collected(prize_name)
signal jump_collected(jump_name)
signal throw_treat

const LR_SPEED = 120
const UD_SPEED = 200
const JUMP_VELOCITY = -400.0
const MIN_LEFT = 30
const MAX_RIGHT = 250

var game_over = false
var end = false
var step = 0
var last_step = -1
var moved_up = false
var released = true
var prize = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _input(event):
	if event.is_action_released("left") or event.is_action_released("right") or event.is_action_released("up") or event.is_action_released("down"):
		released = true
	if event.is_action_pressed("use_item") and prize == true:
		emit_signal("throw_treat")
		prize = false

func _physics_process(_delta):
	# Add the gravity.
#	if not is_on_floor():
#		velocity.y += gravity * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var lr_direction = Input.get_axis("left", "right")
	var ud_direction = Input.get_axis("up", "down")
	if (lr_direction or ud_direction) && not game_over:
		if lr_direction and released:
			if (lr_direction == 1 and position.x < MAX_RIGHT) or (lr_direction == -1 and position.x > MIN_LEFT):
				position.x += lr_direction * LR_SPEED
				released = false
		if ud_direction and end and (not moved_up or ud_direction == 1):
			position.y += ud_direction * UD_SPEED
			released = false
			if ud_direction == -1:
				emit_signal("reached_end")
			
			# i don't think i'll need this since the game should be done by this time
			# don't need to move down if you've already reached the end
			moved_up = ud_direction == -1


func _on_area_2d_area_entered(area):
	var name = area.get_parent().name
	if "Obstacle" in name:
		emit_signal("hit_obstacle")
	if "Prize" in name:
		prize_collected.emit(name)
		prize = true
	if "Jump" in name:
		jump_collected.emit(name)
