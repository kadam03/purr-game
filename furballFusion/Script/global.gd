extends Node

var score: int =0
var highscore: int=0
var gameover: bool = false
var save_path = "user://settings.save"
var volume: float = linear_to_db(0.01)
var sfxvolume: float = linear_to_db(0.3)
var open_menu=false
var block_input=false
var animated_sprites_sized_and_collision = null


func set_volume(linear_volume):
	volume = linear_to_db(linear_volume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), volume)
	save_volume()
	
func get_volume():
	return db_to_linear(volume)
	
func set_volumeSFX(linear_volume):
	sfxvolume = linear_to_db(linear_volume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), sfxvolume)
	save_volumeSFX()
	
func get_volumeSFX():
	return db_to_linear(sfxvolume)

func is_new_highscore():
	if score>highscore:
		return true
	else:
		return false
	
func set_new_highscore():
	if is_new_highscore():
		highscore=score
		store_variables()
		
func store_variables():
	var file = FileAccess.open(save_path,FileAccess.WRITE)
	file.store_var(highscore)
	file.store_var(volume)
	file.store_var(sfxvolume)

func load_variables():
	if FileAccess.file_exists(save_path):
		var file=FileAccess.open(save_path,FileAccess.READ)
		highscore=file.get_var(highscore)
		volume=file.get_var(volume)
		sfxvolume=file.get_var(sfxvolume)
	else:
		print("no savefile")
		

func save_volume():
	store_variables()
	
func save_volumeSFX():
	store_variables()
	
