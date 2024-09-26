extends Node2D


func _on_restart_pressed() -> void:
	get_parent().get_tree().reload_current_scene()


func _on_end_pressed() -> void:
	get_tree().quit()
