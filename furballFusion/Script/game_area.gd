extends Node2D

const COOLDOWN =0.1
var cat_or_ball
var mouse_pressed: bool = false
@onready var lim_left = $SpawnLimiters/LimiterLeft
@onready var lim_right = $SpawnLimiters/LimiterRight
@export var cat_or_ball_scene: PackedScene


var is_click_on_cooldown = false  # To track the 200 ms cooldown

# Timer node to control cooldown
var cooldown_timer = null

func _ready():
	# Create and setup the cooldown timer
	cooldown_timer = Timer.new()
	cooldown_timer.set_wait_time(COOLDOWN) 
	cooldown_timer.set_one_shot(true)  # The timer should stop after one timeout
	cooldown_timer.connect("timeout",  _on_Cooldown_timeout)
	add_child(cooldown_timer)  # Add the timer to the scene


var pos_x
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if mouse_pressed and cat_or_ball != null:
		pos_x = get_viewport().get_mouse_position().x
		if pos_x < lim_left.position.x:
			pos_x = lim_left.position.x
		if pos_x > lim_right.position.x:
			pos_x = lim_right.position.x
		cat_or_ball.position.x = pos_x	
		

func _input(event: InputEvent) -> void:
	# Block further mouse input if cooldown is active
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
