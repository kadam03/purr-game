extends RigidBody2D

const MAX_INIT_INDEX: int  = 2
const SCORE_MULTIPLIER:int  = 10
const IMAGE_SCALE_CONST:int = 30
const KABUM_DRUATION: float = 0.6
const VIBRATION_DURATION: int = 200

@onready var cats_and_balls: AnimatedSprite2D = $cats_and_balls
@onready var merge_sound: AudioStreamPlayer = $merge_sound
@onready var kabum: AnimatedSprite2D = $kabum


var unit_score: int = 0
var animated_sprites_sized_and_collision = {"cat"=[],"ball"=[],"angry"=[]}
var current_id:int = 0
var current_type: String 

func init_variables():
	for animation_name:StringName in cats_and_balls.sprite_frames.get_animation_names():
		var type_id=animation_name.split("_")
		animated_sprites_sized_and_collision[type_id[0]].append(create_dict(animation_name,int(type_id[1])))
	current_id=(randi_range(0,MAX_INIT_INDEX))
	current_type=["cat","ball","ball"][randi_range(0,2)]
	
func create_dict(animation_name,catid):
	var texture = cats_and_balls.sprite_frames.get_frame_texture(animation_name,0)
	var current_scale=get_animation_scale(catid,texture)
	var collision = create_collision_polygon(animation_name,catid,texture,current_scale)
	return {"name":animation_name,"scale":current_scale,"collision":collision}
	
func create_collision_polygon(animation_name,id,texture,scale_factor)->CollisionPolygon2D:
	var image = texture.get_image()
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(image)
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
	var offset=texture.get_size()*scale_factor
	merged_polygon.position = cats_and_balls.position - offset/2
	return merged_polygon

func get_animation_scale(id:int,texture) ->Vector2:
	var texture_size = texture.get_size().x
	var animation_scale = (id+2)*IMAGE_SCALE_CONST/texture_size
	return Vector2(animation_scale,animation_scale)

func set_animation():
	cats_and_balls.play(animated_sprites_sized_and_collision[current_type][current_id].name)

func update_animation_properties():
	unit_score += (current_id + 1) * SCORE_MULTIPLIER
	cats_and_balls.scale=animated_sprites_sized_and_collision[current_type][current_id].scale
	call_deferred("add_child",animated_sprites_sized_and_collision[current_type][current_id].collision)
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
	update_animation_properties()
	connect("body_entered", _on_Ball_collided)
	connect("body_exited", _on_collision_end)

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
			cats_and_balls.play(animated_sprites_sized_and_collision["angry"][current_id].name)

func _on_collision_end(ball):
	if  ball is RigidBody2D and ball.is_in_group(str(current_id)):
		if ball.current_type == "cat" and self.current_type == "cat":
			set_animation()
