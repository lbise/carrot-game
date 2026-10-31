extends Area3D
## A collectible carrot. Drop as many as you like into a level:
## the level finds them automatically (group "carrot").

signal collected

@export var spin_speed := 1.5            ## radians per second
@export var bob_height := 0.15
@export var bob_speed := 2.0

@onready var model: Node3D = $Model
@onready var pickup_sound: AudioStreamPlayer = $PickupSound

var time := randf() * TAU                # so carrots don't all bob in sync
var taken := false

func _ready() -> void:
	add_to_group("carrot")
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	time += delta
	model.rotate_y(spin_speed * delta)
	model.position.y = (sin(time * bob_speed) * 0.5 + 0.5) * bob_height

func _on_body_entered(body: Node3D) -> void:
	if taken or not body.is_in_group("player"):
		return
	taken = true
	collected.emit()
	pickup_sound.pitch_scale = randf_range(0.9, 1.2)
	pickup_sound.play()
	var tween := create_tween()                       # little "pop" then vanish
	tween.tween_property(model, "scale", Vector3.ONE * 1.4, 0.08)
	tween.tween_property(model, "scale", Vector3.ZERO, 0.15)
	await pickup_sound.finished
	queue_free()
