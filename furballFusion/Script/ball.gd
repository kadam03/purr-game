@tool
extends RigidBody2D

@export var ball_value: int = 0
@export var ball_size: float = 1.0
@export var ball_texture: Texture2D

@onready var sprite = $Sprite
@onready var collision_shape = $CollisionShape2D
#
func _ready() -> void:
	collision_shape.shape = collision_shape.shape.duplicate()
	sprite.texture = ball_texture
	sprite.scale = Vector2(ball_size, ball_size)
	update_ball_properties()
	
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		update_ball_properties()

# Update the ball's visual and physical properties
func update_ball_properties() -> void:
	if sprite and ball_texture:
		sprite.texture = ball_texture
		sprite.scale = Vector2(ball_size, ball_size)
	
	# Adjust the collision shape to match the new size
	if collision_shape and collision_shape.shape is CircleShape2D:
		var radius = (sprite.texture.get_size().x / 2)
		collision_shape.shape.radius = radius
