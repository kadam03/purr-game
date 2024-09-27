extends Node2D


@onready var your_score: RichTextLabel = $ColorRect/YourScore

func _ready() -> void:
	if Global.is_new_highscore():
		your_score.text = "NEW Highscore: " + str(Global.score) + "\nOld Highscore: " + str(Global.highscore)
		Global.save_highscore()
	else:
		your_score.text = "Your score: " + str(Global.score) +"\nHighscore: " + str(Global.highscore)

func _on_restart_pressed() -> void:
	Global.gameover=false
	Global.score=0
	get_parent().get_tree().reload_current_scene()


func _on_end_pressed() -> void:
	get_tree().quit()
