extends Node2D

@onready var animations: Node = $Animations
@onready var grid_container: GridContainer = $ColorRect/ScrollContainer/GridContainer


var all_animation={}
var CreateAnimations
func _ready():
	CreateAnimations=preload("res://Script/create_animation.gd").new()
	for folder in Global.FOLDERS:
		var animated_sprite = CreateAnimations.create_animation_from_images(folder)
		animations.add_child(animated_sprite)
		all_animation[animated_sprite.name]=animated_sprite
		create_tile(animated_sprite,StringName(str(Global.selected_sprite_name)) == animated_sprite.name,folder)
	if not Global.selected_sprite_name in all_animation.keys():
		Global.selected_sprite_name=all_animation.keys()[0]
	Global.selected_sprite=all_animation[Global.selected_sprite_name]
	



func create_tile(sprite: AnimatedSprite2D,pressed=false,animal_name:String="Cats"):
	# Create a Sprite node to display the first frame
	var tile_button = TextureButton.new()
	# Get the first frame of the animation (assuming all animations start from index 0)
	var bg_color = Color(180.0/255,180.0/255,160.0/255,255.0/255)
	var bg_selected_color = Color(150.0/255,150.0/255,130.0/255,255.0/255)
	var texture_cat=get_merged_image_from_animations(sprite,animal_name,bg_color)
	var texture_cat_wink=get_merged_image_from_animations(sprite,animal_name,bg_color,1)
	var texture_ball=get_merged_image_from_animations(sprite,"toy",bg_selected_color)
	tile_button.texture_normal = texture_cat
	tile_button.texture_pressed = texture_ball
	tile_button.texture_hover = texture_cat_wink
	tile_button.toggle_mode=true
	tile_button.button_down.connect(_set_buttons_unpressed)
	tile_button.set_meta("related_sprite",sprite)
	tile_button.button_pressed=pressed
	tile_button.toggled.connect(_set_selected_sprite.bind(tile_button))
	tile_button.ignore_texture_size=true
	tile_button.stretch_mode=TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	tile_button.custom_minimum_size=Vector2(298.0,298.0)
	
	grid_container.add_child(tile_button)
	
	
func _set_selected_sprite(toggled_on: bool, button:TextureButton):
	if toggled_on:
		Global.selected_sprite=button.get_meta("related_sprite")
		Global.selected_sprite_name=Global.selected_sprite.name
		Global.set_animated_sprites_dict(Global.selected_sprite)
		Global.store_variables()
		
func merge_textures_into_grid(textures: Array[Texture2D],bg_color:Color) -> Texture2D:
	# Calculate the grid size
	var n:int = ceil(sqrt(textures.size()))
	var tile_width = textures[0].get_width()
	var tile_height = textures[0].get_height()

	var grid_width = n * tile_width
	var grid_height = n * tile_height
	var result_image:Image = Image.create(grid_width, grid_height, false, Image.FORMAT_RGBA8)
	result_image.fill(bg_color)  # Fill with transparent background

	# Copy each texture onto the image at the correct grid position
	for i:int in range(textures.size()):
		var texture = textures[i]
		var image = texture.get_image()

		# Calculate row and column
		var row:int  = floor(i / n)
		var column: int = i % n

		# Calculate position in the final image
		var x_offset = column * tile_width
		var y_offset = row * tile_height
		result_image.blend_rect(image, Rect2(Vector2(0, 0), Vector2(tile_width, tile_height)), Vector2(x_offset, y_offset))

	# Create a Texture2D from the merged image
	var merged_texture = ImageTexture.create_from_image(result_image)
	merged_texture.set_size_override(merged_texture.get_size()*2/n)
	return merged_texture

func get_merged_image_from_animations(animated_sprite:AnimatedSprite2D,type,bg_color,frame=0):
	var textures:Array[Texture2D] = []
	for anim in animated_sprite.sprite_frames.get_animation_names():
		if anim.begins_with(type):
			textures.append(animated_sprite.sprite_frames.get_frame_texture(anim, frame))
	return merge_textures_into_grid(textures,bg_color)
	
func _set_buttons_unpressed():
	for button:TextureButton in grid_container.get_children():
		button.button_pressed=false
