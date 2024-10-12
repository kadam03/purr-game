extends Node2D


@onready var game_over: ColorRect = $GameOver
@onready var your_score: RichTextLabel = $GameOver/YourScore
@onready var settings: ColorRect = $Settings
@onready var node: Node2D = $Settings/Node

@onready var end: Button = $Settings/End
@onready var end2: Button = $GameOver/End
@onready var set_selector: CanvasGroup = $Settings/CanvasGroup
@onready var tab_bar: TabBar = $Settings/TabBar
@onready var volumelabel: Label = $Settings/Node/Label
@onready var volume_sfx: HSlider = $Settings/Node/VolumeSFX
@onready var label_sfx: Label = $Settings/Node/LabelSFX
@onready var volume: HSlider = $Settings/Node/Volume


func _ready() -> void:
	if OS.get_name() == "iOS":
		end.visible=false
		end2.visible=false
	volume.value=Global.get_volume()
	volume_sfx.value=Global.get_volumeSFX()
	volumelabel.text = "Volume: " + str(volume.value*100) +"%"
	label_sfx.text = "Volume: " + str(volume_sfx.value*100) +"%"
		

func _process(_delta: float) -> void:
	if Global.gameover:
		settings.visible=false
		game_over.visible=true
		if Global.is_new_highscore():
			your_score.text = "NEW Highscore: " + str(Global.score) + "\nOld Highscore: " + str(Global.highscore)
			Global.set_new_highscore()
		else:
			your_score.text = "Your score: " + str(Global.score) +"\nHighscore: " + str(Global.highscore)
	else:
		settings.visible=true
		game_over.visible=false
		
	

func _on_restart_pressed() -> void:
	Global.gameover=false
	Global.score=0
	get_tree().reload_current_scene()


func _on_end_pressed() -> void:
	visible=false
	get_tree().quit()



func _on_volume_value_changed(value: float) -> void:
	Global.set_volume(value)
	volumelabel.text = "Volume: " + str(value*100) +"%"


func _on_button_pressed() -> void:
	Global.open_menu=false
	Global.block_input=false


func _on_volume_sfx_value_changed(value: float) -> void:
	Global.set_volumeSFX(value)
	label_sfx.text = "Volume: " + str(value*100) +"%"


func _on_tab_bar_tab_changed(tab: int) -> void:
	if tab==0:
		node.visible=true
		set_selector.visible=false
	elif tab==1:
		node.visible=false
		set_selector.visible=true
