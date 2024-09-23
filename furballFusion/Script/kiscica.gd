extends 'res://Script/new_cica.gd'

# Preload the Ball2 scene
var new_scene = preload("res://Scene/midcica.tscn")
var groupname="kiscicak"

func _ready():
	# Add to the group and connect collision signal
	add_to_group(groupname)
	connect("body_entered", _on_Ball_collided)

func _on_Ball_collided(cica):
	# Ensure that only one ball handles the collision
	cica_pacsi(self,cica,new_scene,groupname)
