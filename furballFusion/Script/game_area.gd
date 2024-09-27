extends Node2D

const COOLDOWN =0.1

@onready var lim_right: Node2D = $SpawnLimiters/LimiterRight
@onready var lim_left: Node2D = $SpawnLimiters/LimiterLeft
@onready var score_label: RichTextLabel = $Score
@onready var highscore: RichTextLabel = $Highscore

@export var cat_or_ball_scene: PackedScene
@export var menu_scene: PackedScene

var cat_or_ball= null
var mouse_pressed: bool = false
var is_click_on_cooldown = false 
var cooldown_timer = null
var pos_x



func _ready():
	Global.load_highscore()
	highscore.text="Highscore: " + str(Global.highscore)
	# Create and setup the cooldown timer
	cooldown_timer = Timer.new()
	cooldown_timer.set_wait_time(COOLDOWN) 
	cooldown_timer.set_one_shot(true)  # The timer should stop after one timeout
	cooldown_timer.connect("timeout",  _on_Cooldown_timeout)
	add_child(cooldown_timer)  # Add the timer to the scene




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	score_label.text = "Score: " + str(Global.score)
	if not Global.gameover and mouse_pressed and cat_or_ball != null:
		pos_x = get_viewport().get_mouse_position().x
		if pos_x < lim_left.position.x:
			pos_x = lim_left.position.x
		if pos_x > lim_right.position.x:
			pos_x = lim_right.position.x
		cat_or_ball.position.x = pos_x	

func _input(event: InputEvent) -> void:
	# Block further mouse input if cooldown is active
	if Global.gameover:
		var menu=menu_scene.instantiate()
		menu.name="menu"
		if not find_child("menu", true, false):
			add_child(menu)
	else:
		# Find the child by name
		var menu_node = get_node_or_null("menu")
		if menu_node:
			# Remove the child from the parent
			remove_child(menu_node)
			# Free the child from memory
			menu_node.queue_free()		
		if is_click_on_cooldown:
			return
		if event.is_action_pressed("mouse_click") and cat_or_ball == null:
			mouse_pressed = true
			cat_or_ball = cat_or_ball_scene.instantiate()
			cat_or_ball.position.y = lim_left.position.y
			#ball.position = Vector2(get_viewport().get_mouse_position().x, lim_left.position.y)
			cat_or_ball.freeze = true
			add_child(cat_or_ball)
			# Start the cooldown timer after kiscica is added
		
		if event.is_action_released("mouse_click") and cat_or_ball != null:
			mouse_pressed = false
			cat_or_ball.freeze = false
			cat_or_ball = null
			is_click_on_cooldown = true
			cooldown_timer.start()
		
func _on_Cooldown_timeout():
	# Reset the cooldown state after 200 milliseconds
	is_click_on_cooldown = false
	
