extends RigidBody2D

const MAX_INIT_INDEX: int  = 2
const SCORE_MULTIPLIER:int  = 10
const IMAGE_SCALE_CONST:int = 30
const KABUM_DRUATION: float = 0.6
const VIBRATION_DURATION: int = 200

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var cats_and_balls: AnimatedSprite2D = $cats_and_balls
@onready var merge_sound: AudioStreamPlayer = $merge_sound


var unit_score: int = 0
var ball_animations : Array[StringName]
var cat_animations : Array[StringName]
var number_of_textures:int
var current_id:int
var current_type: String
var current_animation_name: StringName

func set_animation():
	if current_type=="cat":
		current_animation_name=cat_animations[current_id]
	elif current_type=="ball":
		current_animation_name=ball_animations[current_id]
	elif current_type=="kabum":
		current_animation_name="kabum"
	cats_and_balls.play(current_animation_name)

func init_variables():
	for animation_name:StringName in cats_and_balls.sprite_frames.get_animation_names():
		if animation_name.begins_with("cat"):
			cat_animations.append(animation_name)
		elif animation_name.begins_with("ball"):
			ball_animations.append(animation_name)
	current_id=(randi_range(0,MAX_INIT_INDEX))
	current_type=["cat","ball","ball"][randi_range(0,2)]
	
func update_animation_properties() -> void:
	unit_score += (current_id + 1) * SCORE_MULTIPLIER
	var texture_size =cats_and_balls.sprite_frames.get_frame_texture(current_animation_name,0).get_size().x
	var animation_scale = (current_id+2)*IMAGE_SCALE_CONST/texture_size
	cats_and_balls.scale=Vector2(animation_scale,animation_scale)
	add_to_group(str(current_id))
	if collision_shape and collision_shape.shape is CircleShape2D:
		var radius = (texture_size*animation_scale / 2)
		collision_shape.shape.radius = radius


func _ready():
	collision_shape.shape = collision_shape.shape.duplicate()
	init_variables()
	set_animation()
	update_animation_properties()
	connect("body_entered", _on_Ball_collided)


func _on_Ball_collided(ball):
	if  ball is RigidBody2D and ball.current_type == "ball" and self.current_type == "cat" and ball.is_in_group(str(current_id)) and current_id <= MAX_INIT_INDEX:
		var new_position = (self.position + ball.position) / 2
		Global.score+=ball.unit_score+self.unit_score
		Global.set_new_highscore()
		ball.queue_free()
		current_type="kabum"
		set_animation()
		update_animation_properties()
		merge_sound.play()
		Input.vibrate_handheld(VIBRATION_DURATION)
		await get_tree().create_timer(KABUM_DRUATION).timeout
		remove_from_group(str(current_id))
		current_id+=1
		self.position = new_position
		current_type="cat"
		set_animation()
		update_animation_properties()
