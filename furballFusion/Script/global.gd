extends Node

const IMAGE_SCALE_CONST:int = 20
const TOY_PREFIX="toy"
const FIGHT_PREFIX="angry"
const TILES_SCENE="res://Scene/Tiles.tscn"

var score: int =0
var highscore: int=0
var gameover: bool = false
var save_path = "user://settings.save"
var volume: float = linear_to_db(0.01)
var sfxvolume: float = linear_to_db(0.3)
var open_menu=false
var block_input=false
var animated_sprites_sized_and_collision = {}
var selected_sprite: AnimatedSprite2D = null
var selected_sprite_name=0


func _ready() -> void:
	load_variables()

func set_volume(linear_volume):
	volume = linear_to_db(linear_volume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), volume)
	save_volume()

func get_volume():
	return db_to_linear(volume)

func set_volumeSFX(linear_volume):
	sfxvolume = linear_to_db(linear_volume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), sfxvolume)
	save_volumeSFX()

func get_volumeSFX():
	return db_to_linear(sfxvolume)

func is_new_highscore():
	if score>highscore:
		return true
	else:
		return false

func set_new_highscore():
	if is_new_highscore():
		highscore=score
		store_variables()

func store_variables():
	var file = FileAccess.open(save_path,FileAccess.WRITE)
	file.store_var(highscore)
	file.store_var(volume)
	file.store_var(sfxvolume)
	file.store_var(selected_sprite_name)

func load_variables():
	if FileAccess.file_exists(save_path):
		var file=FileAccess.open(save_path,FileAccess.READ)
		highscore=file.get_var(highscore)
		volume=file.get_var(volume)
		sfxvolume=file.get_var(sfxvolume)
		selected_sprite_name=file.get_var(selected_sprite_name)
	else:
		print("no savefile")

func set_animated_sprites_dict(sprite: AnimatedSprite2D):
	Global.animated_sprites_sized_and_collision[Global.selected_sprite_name]=[]
	Global.animated_sprites_sized_and_collision[TOY_PREFIX]=[]
	Global.animated_sprites_sized_and_collision[FIGHT_PREFIX]=[]
	for animation_name:StringName in sprite.sprite_frames.get_animation_names():
		if "_" in animation_name:
			var type_id=animation_name.split("_")
			Global.animated_sprites_sized_and_collision[type_id[0]].append(create_dict(sprite,animation_name,int(type_id[1])))

func create_dict(sprite: AnimatedSprite2D,animation_name,catid):
	var texture = sprite.sprite_frames.get_frame_texture(animation_name,0)
	var current_scale=get_animation_scale(catid,texture)
	var polygon_points = create_scaled_polygon_points(texture,current_scale)
	return {"name":animation_name,"scale":current_scale,"polygon_points":polygon_points,"texture":texture}

func create_scaled_polygon_points(texture,scale_factor):
	var image = texture.get_image()
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(image)
	var polys = bitmap.opaque_to_polygons(Rect2(Vector2.ZERO, image.get_size()), 5)
	var merged_points = []
	if polys.size() > 0:
		for poly in polys:
			var scaled_points = PackedVector2Array()
			for point in poly:
				scaled_points.append(point * scale_factor)
			merged_points.append_array(scaled_points)
	return merged_points

func get_animation_scale(id:int,texture) ->Vector2:
	var texture_size = texture.get_size().x
	var animation_scale = (id+2)*IMAGE_SCALE_CONST/texture_size
	return Vector2(animation_scale,animation_scale)

func save_volume():
	store_variables()

func save_volumeSFX():
	store_variables()

func get_images_from_tiles_scene()->Dictionary:
	var tiles_scene = preload(TILES_SCENE).instantiate()
	var image_dict:Dictionary = {}
	for category in tiles_scene.get_children():
		if category is Node:
			var images:Array[Image]
			for animal in category.get_children():
				if animal is Sprite2D:
					images.append(animal.texture.get_image())
			image_dict[category.name]=images
	return image_dict

func create_animation_from_images(category: String,images:Array[Image],cols:float=2,rows:float=3)->AnimatedSprite2D:
	if images:
		var animated_sprite= AnimatedSprite2D.new()
		animated_sprite.z_index=1
		animated_sprite.name=category
		var sprite_frames = SpriteFrames.new()
		animated_sprite.frames = sprite_frames
		var anim_index:int = 0
		for sprite_sheet:Image in images:
			var frame_width = sprite_sheet.get_size().x/cols
			var frame_height  = sprite_sheet.get_size().y/rows
			var frames:Array[Texture2D]=[]
			for row in range(rows):
				for col in range(cols):
					var frame_rect = Rect2(col * frame_width, row * frame_height, frame_width, frame_height)
					var texture = ImageTexture.create_from_image(sprite_sheet.get_region(frame_rect))
					frames.append(texture)
			var animal_name = animated_sprite.name+"_"+str(anim_index)
			var toy_name = Global.TOY_PREFIX+"_"+str(anim_index)
			var fight_name = Global.FIGHT_PREFIX+"_"+str(anim_index)
			sprite_frames.add_animation(animal_name)
			sprite_frames.add_animation(toy_name)
			sprite_frames.add_animation(fight_name)
			sprite_frames.add_frame(animal_name,frames[0],20)
			sprite_frames.add_frame(animal_name,frames[1],1)
			sprite_frames.add_frame(animal_name,frames[0],20)
			sprite_frames.add_frame(animal_name,frames[2],1)
			sprite_frames.add_frame(fight_name,frames[0],10)
			sprite_frames.add_frame(fight_name,frames[3],1)
			sprite_frames.add_frame(toy_name,frames[4],1)
			anim_index+=1
		return animated_sprite
	else:
		return null
