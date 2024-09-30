extends RigidBody2D

const MAX_INIT_INDEX: int  = 2
const SCORE_MULTIPLIER:int  = 10
const IMAGE_SCALE_CONST:int = 30
const KABUM_DRUATION: float = 0.6
const VIBRATION_DURATION: int = 200

@onready var cats_and_balls: AnimatedSprite2D = $cats_and_balls
@onready var merge_sound: AudioStreamPlayer = $merge_sound
@onready var kabum: AnimatedSprite2D = $kabum



#var collision_polygon: CollisionPolygon2D
var unit_score: int = 0
var ball_animations: Array[StringName] = []
var cat_animations: Array[StringName] = []
var angry_animations: Array[StringName] = []
var number_of_textures:int
var current_id:int = 0
var current_type: String 
var current_animation_name: StringName
var previous_animation_name: StringName

func init_variables():
	for animation_name:StringName in cats_and_balls.sprite_frames.get_animation_names():
		if animation_name.begins_with("cat"):
			cat_animations.append(animation_name)
		elif animation_name.begins_with("ball"):
			ball_animations.append(animation_name)
		elif animation_name.begins_with("angry"):
			angry_animations.append(animation_name)
	current_id=(randi_range(0,MAX_INIT_INDEX))
	current_type=["cat","ball","ball"][randi_range(0,2)]
	
	
func create_collision_polygon()->CollisionPolygon2D:
	var image = get_animationTexture().get_image()
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(image)
	var scale_factor=get_animation_scale()
	var polys = bitmap.opaque_to_polygons(Rect2(Vector2.ZERO, image.get_size()), 5)
	var merged_polygon = CollisionPolygon2D.new()
	var merged_points = []
	if polys.size() > 0:
		for poly in polys:
			var scaled_points = PackedVector2Array()
			for point in poly:
				scaled_points.append(point * scale_factor)
			merged_points.append_array(scaled_points)
	merged_polygon.polygon = merged_points
	return merged_polygon

	
func add_or_replace_collision_polygon():
	for child in get_children():
		if child is CollisionPolygon2D:
			child.queue_free()
	var offset=get_animationTexture().get_size()*cats_and_balls.scale
	var collision_polygon2=create_collision_polygon()
	#call_deferred("add_child",collision_polygon2)
	#collision_polygon2.call_deferred("position",cats_and_balls.position - offset/2)
	collision_polygon2.position = cats_and_balls.position - offset/2
	add_child(collision_polygon2)


	
func get_animationTexture()->Texture2D:
	return cats_and_balls.sprite_frames.get_frame_texture(current_animation_name,0)
		

func get_animation_scale() ->Vector2:
	var texture_size = get_animationTexture().get_size().x
	var animation_scale = (current_id+2)*IMAGE_SCALE_CONST/texture_size
	return Vector2(animation_scale,animation_scale)

func set_animation():
	if current_type=="cat":
		current_animation_name=cat_animations[current_id]
	elif current_type=="ball":
		current_animation_name=ball_animations[current_id]
	cats_and_balls.play(current_animation_name)



func update_animation_properties():
	unit_score += (current_id + 1) * SCORE_MULTIPLIER
	cats_and_balls.scale=get_animation_scale()
	add_or_replace_collision_polygon()
	self.mass =float(current_id + 1)
	add_to_group(str(current_id))
	
func play_kabumm():
	cats_and_balls.self_modulate.a=0.2
	var kabumm_scale = (current_id+2)*IMAGE_SCALE_CONST/512.0
	kabum.visible=true
	kabum.scale=Vector2(kabumm_scale,kabumm_scale)
	kabum.play("kabum")
	merge_sound.play()
	Input.vibrate_handheld(VIBRATION_DURATION)
	await get_tree().create_timer(KABUM_DRUATION).timeout
	kabum.visible=false
	cats_and_balls.self_modulate.a=1
	

func _ready():
	init_variables()
	set_animation()
	add_or_replace_collision_polygon()
	update_animation_properties()
	connect("body_entered", _on_Ball_collided)


func _on_Ball_collided(ball):
	if  ball is RigidBody2D and ball.is_in_group(str(current_id)):
		if ball.current_type == "ball" and current_id <= MAX_INIT_INDEX:
			var new_position = (self.position + ball.position) / 2
			Global.score+=ball.unit_score+self.unit_score
			Global.set_new_highscore()
			ball.queue_free()
			self.position = new_position
			remove_from_group(str(current_id))
			current_id+=1
			play_kabumm()
			set_animation()
			update_animation_properties()
		elif ball.current_type == "cat" and self.current_type == "cat":
			cats_and_balls.play(angry_animations[current_id])
