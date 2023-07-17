extends CharacterBody2D


const SPEED = 6500.0
const JUMP_VELOCITY = -400.0
const MIN_LEFT = 100
const MAX_RIGHT = 200

var game_over = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var released = true

func _input(event):
	if event.is_action_released("left") or event.is_action_released("right"):
		released = true

func _physics_process(_delta):
	# Add the gravity.
#	if not is_on_floor():
#		velocity.y += gravity * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")
	if direction && released && not game_over:
		if (direction == -1 and position.x > MIN_LEFT) or (direction == 1 and position.x < MAX_RIGHT):
			velocity.x = direction * SPEED
			released = false
	else:
		# this prevents sliding (won't need it eventually)
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
