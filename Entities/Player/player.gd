extends CharacterBody3D

@onready var neck: Node3D = $Neck
@export var MOUSE_SENS:float = 0.01
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

func _input(event: InputEvent) -> void:
	if (event is InputEventMouseMotion):
		var mouse_motion:Vector2 = event.relative
		print(mouse_motion)
		rotate_y(-(mouse_motion.x * MOUSE_SENS))
		neck.rotate_x(-(mouse_motion.y * MOUSE_SENS))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("space") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
