extends Node3D

@export var interact_range:float = 10.0
@export var tooltip_button:String = "Q"
@export var tooltip_text:String = "Push"

func interact(player):
	pass

func get_available(player:CharacterBody3D):
	"""Player calls this to find in range interactable items"""
	if (player.global_position.distance_squared_to(global_position) <= interact_range
			and player.flashlightView.visible):
		player.in_range(self)
	else:
		player.out_range(self)
