extends Camera3D
## Fixed-angle camera that follows a target smoothly. No mouse needed.
## The camera always sits at target + offset, so you can put the rabbit
## anywhere in a level: the camera position in the editor doesn't matter.

@export var target: Node3D
@export var offset := Vector3(0, 6, 8)   ## up 6 m, back 8 m: progress goes "up the screen" (-Z)
@export var look_height := 0.5           ## aim this far above the target's feet
@export var smoothing := 5.0             ## higher = snappier follow

func _ready() -> void:
	top_level = true
	if target:
		global_position = target.global_position + offset
		look_at(target.global_position + Vector3.UP * look_height)

func _physics_process(delta: float) -> void:
	if target:
		var goal := target.global_position + offset
		global_position = global_position.lerp(goal, 1.0 - exp(-smoothing * delta))
