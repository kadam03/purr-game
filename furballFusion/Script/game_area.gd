extends Node2D

var ballscene
var ball
var mouse_pressed: bool = false
@onready var lim_left = $SpawnLimiters/LimiterLeft
@onready var lim_right = $SpawnLimiters/LimiterRight

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


var pos_x
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if mouse_pressed and ball != null:
		pos_x = get_viewport().get_mouse_position().x
		if pos_x < lim_left.position.x:
			pos_x = lim_left.position.x
		if pos_x > lim_right.position.x:
			pos_x = lim_right.position.x
		ball.position.x = pos_x	
		
#func _process(delta: float) -> void:
	#if mouse_pressed and ball != null:
		#var pos_x = get_viewport().get_mouse_position().x
		## Constrain position within limits
		#pos_x = clamp(pos_x, lim_left.position.x, lim_right.position.x)
		## Move the ball along the X-axis only
		#ball.position.x = pos_x

func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("mouse_click") and ball == null:
		mouse_pressed = true
		ballscene = load("res://Scene/Ball.tscn")
		ball = ballscene.instantiate()
		ball.position.y = lim_left.position.y
		#ball.position = Vector2(get_viewport().get_mouse_position().x, lim_left.position.y)
		ball.freeze = true
		add_child(ball)
	
	if event.is_action_released("mouse_click") and ball != null:
		mouse_pressed = false
		ball.freeze = false
		ball = null
		
		
