extends CanvasLayer
## Carrot counter and the big celebration message.

@export var win_text := "Bravo !"

@onready var counter: Label = $Counter
@onready var win_label: Label = $WinLabel

func _ready() -> void:
	win_label.visible = false

func show_count(found: int, total: int) -> void:
	counter.text = "%d / %d" % [found, total]
	var tween := create_tween()                        # counter "pops" on each carrot
	counter.pivot_offset = counter.size / 2
	tween.tween_property(counter, "scale", Vector2.ONE * 1.3, 0.08)
	tween.tween_property(counter, "scale", Vector2.ONE, 0.2)

func show_win() -> void:
	win_label.text = win_text
	win_label.visible = true
	win_label.pivot_offset = win_label.size / 2
	win_label.scale = Vector2.ZERO
	create_tween().tween_property(win_label, "scale", Vector2.ONE, 0.6) \
			.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
