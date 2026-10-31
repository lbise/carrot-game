extends CharacterBody3D
## The player rabbit: move, hop, jump, celebrate.
## Same state-machine pattern as Lesson 7, minus roll and sprint (simpler for 4-6 year olds).
## The "animation" is squash & stretch on the Model node. Swap in a real AnimationPlayer later.

enum State { IDLE, MOVE, AIR, LAND, CELEBRATE }

@export_group("Movement")
@export var speed := 4.5
@export var jump_velocity := 6.0
@export var turn_speed := 12.0
@export var fall_limit := -10.0          ## below this height the rabbit pops back to its start

@export_group("Juice")
@export var hop_height := 0.12           ## little bounce while running, in metres
@export var hop_rate := 9.0              ## bounces per second x 2pi... feel free to tweak
@export var squash := Vector3(1.3, 0.7, 1.3)
@export var land_thud_speed := 2.5      ## only landings faster than this (m/s) thud and squash
@export var stretch := Vector3(0.8, 1.3, 0.8)

@onready var model: Node3D = $Model
@onready var jump_sound: AudioStreamPlayer = $JumpSound
@onready var land_sound: AudioStreamPlayer = $LandSound
@onready var confetti: CPUParticles3D = $Confetti

var state := State.IDLE
var start_position: Vector3
var hop_time := 0.0
var scale_tween: Tween
var fall_speed := 0.0                    # fastest downward speed during the current fall

func _ready() -> void:
	add_to_group("player")
	start_position = global_position

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	if global_position.y < fall_limit:
		global_position = start_position     # no losing: just pop back
		velocity = Vector3.ZERO

	var direction := camera_relative_input()

	match state:
		State.IDLE, State.MOVE:
			walk(direction, delta)
			if Input.is_action_just_pressed("jump") and is_on_floor():
				jump()
			elif not is_on_floor():
				change_state(State.AIR)
			elif direction.length() > 0.01:
				change_state(State.MOVE)
			else:
				change_state(State.IDLE)
		State.AIR:
			walk(direction, delta)
			fall_speed = maxf(fall_speed, -velocity.y)
			if is_on_floor():
				change_state(State.LAND)
		State.LAND:
			walk(direction, delta)
			change_state(State.MOVE if direction.length() > 0.01 else State.IDLE)
		State.CELEBRATE:
			velocity.x = 0
			velocity.z = 0
			if is_on_floor():                # happy bouncing on the spot
				velocity.y = jump_velocity * 0.7
				squash_stretch(stretch, 0.25)
			model.rotate_y(8.0 * delta)

	move_and_slide()
	update_hop(delta)

## WASD / stick, rotated so "up" always means "away from the camera".
func camera_relative_input() -> Vector3:
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var cam := get_viewport().get_camera_3d()
	var yaw := cam.global_rotation.y if cam else 0.0
	return Vector3(input.x, 0, input.y).rotated(Vector3.UP, yaw)

func change_state(new_state: State) -> void:
	if new_state == state:
		return
	state = new_state
	match state:
		State.LAND:
			if fall_speed > land_thud_speed:
				land_sound.play()
				squash_stretch(squash, 0.18)
			fall_speed = 0.0
		State.CELEBRATE:
			confetti.restart()

func jump() -> void:
	velocity.y = jump_velocity
	jump_sound.pitch_scale = randf_range(0.9, 1.1)
	jump_sound.play()
	squash_stretch(stretch, 0.3)
	change_state(State.AIR)

func walk(direction: Vector3, delta: float) -> void:
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	if direction.length() > 0.01:
		var target_yaw := atan2(-direction.x, -direction.z)
		model.rotation.y = lerp_angle(model.rotation.y, target_yaw, turn_speed * delta)

## Bunny-hop bob while running on the ground.
func update_hop(delta: float) -> void:
	if state == State.MOVE:
		hop_time += delta * hop_rate
		model.position.y = absf(sin(hop_time)) * hop_height
	else:
		hop_time = 0.0
		model.position.y = move_toward(model.position.y, 0.0, delta)

## Briefly squash or stretch the model, then spring back to normal.
func squash_stretch(target: Vector3, duration: float) -> void:
	if scale_tween:
		scale_tween.kill()
	scale_tween = create_tween()
	scale_tween.tween_property(model, "scale", target, duration * 0.3)
	scale_tween.tween_property(model, "scale", Vector3.ONE, duration * 0.7) \
			.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func celebrate() -> void:
	change_state(State.CELEBRATE)
