extends Node2D

@onready var score: RichTextLabel = $Score
@onready var highscore: RichTextLabel = $Highscore
@onready var music: AudioStreamPlayer = $music
@onready var menu_scene: Node2D = $Menu_scene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Global.load_variables()
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), Global.volume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), Global.sfxvolume)
	
	highscore.text="Highscore: " + str(Global.highscore)
	music.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	score.text = "Score: " + str(Global.score)
	highscore.text="Highscore: " + str(Global.highscore)
	
func _input(_event: InputEvent) -> void:
	if Global.gameover or Global.open_menu:
		Global.block_input=true
		menu_scene.visible=true
	else:
		Global.block_input=false
		Global.open_menu=false
		menu_scene.visible=false
		


func _on_menu_button_pressed() -> void:
	Global.open_menu=true
