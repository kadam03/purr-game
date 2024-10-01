extends Node2D



func _on_body_entered(_body: Node2D) -> void:
	Global.gameover=true
	Global.open_menu=false
