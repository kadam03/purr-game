extends Node2D

const COOLDOWN =0.25

@onready var lim_right: Node2D = $SpawnLimiters/LimiterRight
@onready var lim_left: Node2D = $SpawnLimiters/LimiterLeft



@export var animal_or_toy_scene: PackedScene

var animal_or_toy= null
var mouse_pressed: bool = false
var is_click_on_cooldown = false 
var cooldown_timer = null


func _ready():
	# Create and setup the cooldown timer
	cooldown_timer = Timer.new()
	cooldown_timer.set_wait_time(COOLDOWN) 
	cooldown_timer.set_one_shot(true)  # The timer should stop after one timeout
	cooldown_timer.connect("timeout",  _on_Cooldown_timeout)
	add_child(cooldown_timer)  # Add the timer to the scene


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not Global.gameover and mouse_pressed and animal_or_toy != null:
		var pos_x = get_viewport().get_mouse_position().x
		if pos_x < lim_left.position.x:
			pos_x = lim_left.position.x
		if pos_x > lim_right.position.x:
			pos_x = lim_right.position.x
		animal_or_toy.position.x = pos_x	

func _input(event: InputEvent) -> void:
	# Block further mouse input if cooldown is active
	if is_click_on_cooldown or Global.block_input:
		return
	else:
		# Find the child by name
		if event.is_action_pressed("mouse_click") and animal_or_toy == null and get_viewport().get_mouse_position().y> lim_right.position.y:
			mouse_pressed = true
			animal_or_toy = animal_or_toy_scene.instantiate()
			animal_or_toy.position.y = lim_right.position.y
			#ball.position = Vector2(get_viewport().get_mouse_position().x, lim_left.position.y)
			animal_or_toy.freeze = true
			add_child(animal_or_toy)
			# Start the cooldown timer after kiscica is added
		
		if event.is_action_released("mouse_click") and animal_or_toy != null:
			animal_or_toy.position.y = lim_left.position.y
			animal_or_toy.laser_visibility=false
			mouse_pressed = false
			animal_or_toy.freeze = false
			animal_or_toy = null
			is_click_on_cooldown = true
			cooldown_timer.start()
		
func _on_Cooldown_timeout():
	# Reset the cooldown state after 200 milliseconds
	is_click_on_cooldown = false
	
