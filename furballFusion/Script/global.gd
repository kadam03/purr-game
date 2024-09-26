extends Node

var score: int =0
var gameover: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


signal score_changed(new_value)

func set_score(value):
	score = value
	emit_signal("score_changed", value)
