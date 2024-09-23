extends RigidBody2D

@export var new_scene:PackedScene
@export var groupname:String

func _ready():
	# Add to the group and connect collision signal
	add_to_group(groupname)
	connect("body_entered", _on_Ball_collided)

func _on_Ball_collided(cica):
	# Ensure that only one ball handles the collision
	cica_pacsi(self,cica,new_scene,groupname)


func cica_pacsi(egy_cica,ket_cica,new_scene,group):
	# Ensure that only one ball handles the collision
	print(group)
	if egy_cica.get_rid() < ket_cica.get_rid() and ket_cica.is_in_group(group):
		
		# Get the position where the new Ball2 should be instanced
		var new_position = (egy_cica.position + ket_cica.position) / 2
		
		# Replace both Balls with a Ball2 instance
		var new_cica = new_scene.instantiate()
		new_cica.position = new_position
		
		# Add the new Ball2 to the scene tree
		egy_cica.get_parent().add_child(new_cica)
		
		# Remove both Balls from the scene
		egy_cica.queue_free()
		ket_cica.queue_free()
