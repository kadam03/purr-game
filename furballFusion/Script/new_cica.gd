extends RigidBody2D

@export var new_scene:PackedScene
var groupname:String

@export var ball_value: int = 0
@export var ball_size: float = 1.0
@export var ball_textures: Array[Texture2D]
@onready var sprite = $Sprite
@onready var collision_shape = $CollisionShape2D
var ball_texture:Texture2D
var number_of_textures:int
var curent_id:int
func _ready():
	number_of_textures = ball_textures.size()
	curent_id=(randi() % number_of_textures-1)
	ball_texture = ball_textures[curent_id]
	collision_shape.shape = collision_shape.shape.duplicate()
	sprite.texture = ball_texture
	sprite.scale = Vector2(ball_size, ball_size)
	update_ball_properties()
	add_to_group(ball_texture.resource_path)
	connect("body_entered", _on_Ball_collided)

func _process(_delta: float) -> void:
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
		
		
func _on_Ball_collided(catball:RigidBody2D):

	var  group=self.ball_texture.resource_path
	if self.get_rid() < catball.get_rid() and catball.is_in_group(group) and curent_id < number_of_textures-1:
		
		# Get the position where the new Ball2 should be instanced
		var new_position = (self.position + catball.position) / 2
		
		# Replace both Balls with a Ball2 instance
		if not new_scene:
			new_scene=load("res://Scene/Ball.tscn")
		var new_cica = new_scene.instantiate()
		ball_texture = ball_textures[ball_textures.find(catball.ball_texture,0) + 1]
		new_cica.position = new_position
		
		# Add the new Ball2 to the scene tree
		catball.get_parent().add_child(new_cica)
		
		# Remove both Balls from the scene
		self.queue_free()
		catball.queue_free()
