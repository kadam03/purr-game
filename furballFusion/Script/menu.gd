extends Node2D


func _on_restart_pressed() -> void:
	Global.gameover=false
	Global.score=0
	get_parent().get_tree().reload_current_scene()


func _on_end_pressed() -> void:
	get_tree().quit()
