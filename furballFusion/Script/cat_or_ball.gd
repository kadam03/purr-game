extends RigidBody2D

const MAX_INIT_INDEX = 2


@export var ball_textures: Array[Texture2D]
@export var cat_textures: Array[Texture2D]
@onready var sprite: Sprite2D = $Sprite
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var ball_value: int = 0
var textures=[]
var texture:Texture2D
var number_of_textures:int
var current_id:int
var current_type: String

func init_variables():
	number_of_textures = ball_textures.size()
	for index in range(number_of_textures):
		textures.append({"id": index, "cat":cat_textures[index],"ball":ball_textures[index]})
	current_id=(randi_range(0,min(number_of_textures-1,MAX_INIT_INDEX)))
	current_type=["cat","ball","ball"][randi_range(0,2)]
	
# Update the ball's visual and physical properties
func update_ball_properties(current_id,current_type) -> void:
	ball_value = (current_id + 1) * 10
	texture = textures[current_id][current_type]
	var texture_size =texture.get_size().x
	var ball_size=(current_id+2)*30/texture_size
	add_to_group(str(current_id))
	if sprite and texture:
		sprite.texture = texture
		sprite.scale = Vector2(ball_size, ball_size)
	# Adjust the collision shape to match the new size
	if collision_shape and collision_shape.shape is CircleShape2D:
		var radius = (texture_size*ball_size / 2)
		collision_shape.shape.radius = radius


func _ready():
	#This is needed to have individual shape size to all objects
	collision_shape.shape = collision_shape.shape.duplicate()
	init_variables()
	update_ball_properties(current_id,current_type)
	connect("body_entered", _on_Ball_collided)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		update_ball_properties(self.current_id,self.current_type)


func _on_Ball_collided(ball):
	if  ball is RigidBody2D and ball.current_type == "ball" and self.current_type == "cat" and ball.is_in_group(str(current_id)) and current_id < number_of_textures-1:
		remove_from_group(str(current_id))
		current_id+=1
		var new_position = (self.position + ball.position) / 2
		self.position = new_position
		update_ball_properties(current_id,"cat")
		Global.score+=ball.ball_value+self.ball_value
		ball.queue_free()
