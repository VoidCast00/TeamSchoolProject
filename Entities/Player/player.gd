extends CharacterBody3D

@onready var neck: Node3D = $Neck
@export var SENS: float = 0.15

# Ground movement
const MAX_SPEED := 7.0
const RUN_MULT := 1.6
const GROUND_ACCEL := 80.0
const FRICTION := 8.0
const STOP_SPEED := 2.0

# Air movement (the bunnyhop magic)
const AIR_ACCEL := 90.0
const AIR_MAX_SPEED := 1.2    # low cap — this is what enables air-strafing gains
const AIR_STEER := 25.0       # how hard you can steer existing momentum mid-air (deg/sec-ish)

# Jump
const JUMP_VELOCITY := 5.5
const JUMP_BUFFER := 0.12
const COYOTE_TIME := 0.10
const AUTOHOP := true        # hold space to chain hops like q3/source

var _jump_buffer := 0.0
var _coyote := 0.0
var _was_on_floor := false


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_motion: Vector2 = event.screen_relative
		var d := SENS * 0.6 + 0.2
		var sens := deg_to_rad(d * d * d * 8.0 * 0.15)
		rotate_y(-(mouse_motion.x * sens))
		neck.rotate_x(-(mouse_motion.y * sens))
		neck.rotation.x = clamp(neck.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	


func _physics_process(delta: float) -> void:
	var on_floor := is_on_floor()

	# Coyote + jump buffer timers
	if on_floor:
		_coyote = COYOTE_TIME
	else:
		_coyote = max(0.0, _coyote - delta)

	if Input.is_action_just_pressed("space"):
		_jump_buffer = JUMP_BUFFER
	else:
		_jump_buffer = max(0.0, _jump_buffer - delta)

	# Gravity
	if not on_floor:
		velocity += get_gravity() * delta

	# Wish direction from input (world space, horizontal)
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var wish_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	wish_dir.y = 0.0
	if wish_dir.length() > 0.001:
		wish_dir = wish_dir.normalized()
	else:
		wish_dir = Vector3.ZERO

	var running := Input.is_action_pressed("run")
	var wish_speed := MAX_SPEED * (RUN_MULT if running else 1.0)

	if on_floor:
		# Friction — only when no input OR to shed oversize speed modestly
		_apply_friction(delta)
		_accelerate(wish_dir, wish_speed, GROUND_ACCEL, delta)
	else:
		# Air strafe: adds speed only when wish-dir is near-perpendicular to velocity
		_accelerate(wish_dir, wish_speed, AIR_ACCEL, delta, true)
		# Air steering: rotates existing horizontal velocity toward wish_dir without adding speed
		_air_steer(wish_dir, delta)

	# Jump (with buffer + coyote, optional autohop)
	var want_jump := _jump_buffer > 0.0 or (AUTOHOP and Input.is_action_pressed("space"))
	if want_jump and _coyote > 0.0:
		velocity.y = JUMP_VELOCITY
		_jump_buffer = 0.0
		_coyote = 0.0

	move_and_slide()
	_was_on_floor = on_floor


func _apply_friction(delta: float) -> void:
	var v := Vector3(velocity.x, 0, velocity.z)
	var speed := v.length()
	if speed < 0.01:
		velocity.x = 0.0
		velocity.z = 0.0
		return
	var control := speed if speed > STOP_SPEED else STOP_SPEED
	var drop := control * FRICTION * delta
	var new_speed = max(speed - drop, 0.0) / speed
	velocity.x *= new_speed
	velocity.z *= new_speed


func _air_steer(wish_dir: Vector3, delta: float) -> void:
	if wish_dir == Vector3.ZERO:
		return
	var v := Vector3(velocity.x, 0, velocity.z)
	var speed := v.length()
	if speed < 0.1:
		# No momentum yet — give a little nudge so standing-jumps can move
		velocity.x += wish_dir.x * AIR_ACCEL * delta * 0.1
		velocity.z += wish_dir.z * AIR_ACCEL * delta * 0.1
		return
	var dir := v / speed
	# Rotate current direction toward wish_dir, preserve magnitude
	var new_dir := dir.lerp(wish_dir, clamp(AIR_STEER * delta, 0.0, 1.0)).normalized()
	velocity.x = new_dir.x * speed
	velocity.z = new_dir.z * speed


func _accelerate(wish_dir: Vector3, wish_speed: float, accel: float, delta: float, air: bool = false) -> void:
	if wish_dir == Vector3.ZERO:
		return
	# Project current horizontal velocity onto wish direction
	var cur_v := Vector3(velocity.x, 0, velocity.z)
	var current_speed := cur_v.dot(wish_dir)
	# This is the Quake trick: in air, wish_speed is capped tiny (AIR_MAX_SPEED),
	# so add_speed stays positive as long as you keep turning your view + strafing.
	var cap := AIR_MAX_SPEED if air else wish_speed
	var add_speed := cap - current_speed
	if add_speed <= 0.0:
		return
	var accel_speed := accel * delta * wish_speed
	accel_speed = min(accel_speed, add_speed)
	velocity.x += accel_speed * wish_dir.x
	velocity.z += accel_speed * wish_dir.z
