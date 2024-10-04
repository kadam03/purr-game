extends Node

const IMAGE_SCALE_CONST:int = 30
const TILES_FOLDER="res://Asset/Image/Tiles/"
const TOY_PREFIX="toy"
const FIGHT_PREFIX="angry"

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
var folders = ["Cats","Dogs"]


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
	Global.animated_sprites_sized_and_collision["toy"]=[]
	Global.animated_sprites_sized_and_collision["angry"]=[]
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
	
const FOLDERS=["Cats","Dogs"]
const PNG_PREFIXES=["cat","dog"]
const IMAGE_RANGE=5

func get_images() -> Dictionary:
	var image_pathes = {}

	for i  in range(FOLDERS.size()):
		var folder = FOLDERS[i]
		image_pathes[folder]=[]
		for j in range(IMAGE_RANGE):
			image_pathes[folder].append(TILES_FOLDER+folder+"/"+PNG_PREFIXES[i]+str(j)+".png")
	return image_pathes
