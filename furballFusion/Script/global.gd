extends Node

var score: int =0
var highscore: int
var gameover: bool = false
var save_path = "user://score.save"


func is_new_highscore():
	if score>highscore:
		return true
	else:
		return false
	
func set_new_highscore():
	if is_new_highscore():
		highscore=score
		
		
func save_highscore():
	set_new_highscore()
	var file = FileAccess.open(save_path,FileAccess.WRITE)
	file.store_var(highscore)
	
func load_highscore():
	if FileAccess.file_exists(save_path):
		var file=FileAccess.open(save_path,FileAccess.READ)
		highscore=file.get_var(highscore)
	else:
		print("no savefile")
		highscore=0
