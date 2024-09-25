extends RigidBody2D

const MAX_INIT_INDEX = 2


@export var ball_value: int = 0
@export var ball_textures: Array[Texture2D]
@export var cat_textures: Array[Texture2D]
@onready var sprite = $Sprite
@onready var collision_shape = $CollisionShape2D

var textures=[]
var texture:Texture2D
var number_of_textures:int
var current_id:int
var current_type: String


func _ready():
	number_of_textures = ball_textures.size()
	for index in range(number_of_textures):
		textures.append({"id": index, "cat":cat_textures[index],"ball":ball_textures[index]})
	current_id=(randi_range(0,min(number_of_textures-1,MAX_INIT_INDEX)))
	current_type=["cat","ball"][randi_range(0,1)]
	texture = textures[current_id][current_type]
	collision_shape.shape = collision_shape.shape.duplicate()
	update_ball_properties()
	connect("body_entered", _on_Ball_collided)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		update_ball_properties()


# Update the ball's visual and physical properties
func update_ball_properties() -> void:
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
		
		
func _on_Ball_collided(catball:RigidBody2D):

	if catball.current_type == "ball" and self.current_type == "cat" and catball.is_in_group(str(current_id)) and current_id < number_of_textures-1:
		remove_from_group(str(current_id))
		current_id+=1
		var new_position = (self.position + catball.position) / 2
		self.position = new_position
		self.texture = textures[current_id]["cat"]
		update_ball_properties()
		catball.queue_free()
