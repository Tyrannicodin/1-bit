extends Node3D


@export var interact_range:float = 50.0
@export var furniture_type:String = ""
@export var tooltip_button:String = "Q"
@export var tooltip_text:String = "Search"

@onready var animator = $AnimationPlayer

func get_available(player:CharacterBody3D):
	if (player.global_position.distance_squared_to(global_position) <= interact_range
			and player.flashlightView.visible):
		player.in_range(self)
	else:
		player.out_range(self)

func interact(player:CharacterBody3D):
	if player.global_position.distance_squared_to(global_position) > interact_range or player.spectralView.visible:
		return
	if animator.has_animation("animation_" + furniture_type + "_search"):
		animator.play("animation_" + furniture_type + "_search")
