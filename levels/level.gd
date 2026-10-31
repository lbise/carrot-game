extends Node3D
## Attach to the root of any level. Counts every carrot in the level,
## updates the HUD, and celebrates when all are found. Level designers
## just place rabbit, camera, HUD and carrots: no wiring needed.

signal all_carrots_collected

@onready var rabbit: Node = $Rabbit
@onready var hud: CanvasLayer = $HUD
@onready var win_jingle: AudioStreamPlayer = $WinJingle

var found := 0
var total := 0

func _ready() -> void:
	var carrots := get_tree().get_nodes_in_group("carrot")
	total = carrots.size()
	for carrot in carrots:
		carrot.collected.connect(_on_carrot_collected)
	all_carrots_collected.connect(rabbit.celebrate)
	all_carrots_collected.connect(hud.show_win)
	all_carrots_collected.connect(win_jingle.play)
	hud.show_count(found, total)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()

func _on_carrot_collected() -> void:
	found += 1
	hud.show_count(found, total)
	if found == total:
		all_carrots_collected.emit()
