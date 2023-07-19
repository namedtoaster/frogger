extends CharacterBody2D


const LR_SPEED = 6500.0
const UD_SPEED = 9500.0
const JUMP_VELOCITY = -400.0
const MIN_LEFT = 100
const MAX_RIGHT = 200

var game_over = false
var end = false
var step = 0
var last_step = -1
var moved_up = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var released = true

func _input(event):
	if event.is_action_released("left") or event.is_action_released("right") or event.is_action_released("up") or event.is_action_released("down"):
		released = true

func _physics_process(_delta):
	# Add the gravity.
#	if not is_on_floor():
#		velocity.y += gravity * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var lr_direction = Input.get_axis("left", "right")
	var ud_direction = Input.get_axis("up", "down")
	if (lr_direction or ud_direction) && released && not game_over:
		if (lr_direction == -1 and position.x > MIN_LEFT) or (lr_direction == 1 and position.x < MAX_RIGHT):
			velocity.x = lr_direction * LR_SPEED
			released = false
		if ud_direction and end and (not moved_up or ud_direction == 1):
			velocity.y = ud_direction * UD_SPEED
			released = false
			
			moved_up = ud_direction == -1
	else:
		# this prevents sliding
		velocity.x = move_toward(velocity.x, 0, LR_SPEED)
		velocity.y = move_toward(velocity.y, 0, LR_SPEED)

	move_and_slide()
