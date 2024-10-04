extends Node



func preload_images_from_folder(folder)->Array[Image]:
	var images:Array[Image] = []
	for path in Global.get_images()[folder]:
		var comtexture = ResourceLoader.load(path)
		var image:Image = comtexture.get_image()
		images.append(image)
	return images

func create_animation_from_images(category: String,images:Array[Image],cols:float=2,rows:float=3)->AnimatedSprite2D:
	#var images:Array[Image] = preload_images_from_folder(folder)
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
			
#func _ready() -> void:
	#var anim = create_animation_from_images("res://Asset/Image/Tiles/Cats")
	#add_child(anim)
	#anim.visible=true
