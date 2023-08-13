extends Node3D


@export var interact_range:float = 50.0
@export var furniture_type:String = ""
@export var tooltip_button:String = "Q"
@export var tooltip_text:String = "Search"
@export var items:int = 1

var player_searching = null

@onready var animator = $AnimationPlayer

func _ready():
	animator.connect("animation_finished", interaction_complete)

func _process(_d):
	"""Whenever we are searching, check we are still in flashlight mode and within range"""
	if player_searching:
		if (player_searching.global_position.distance_squared_to(global_position) > interact_range
			or not player_searching.flashlightView.visible):
			player_searching = null
			animator.stop()

func get_available(player:CharacterBody3D):
	"""Player calls this to find in range interactable items"""
	if (player.global_position.distance_squared_to(global_position) <= interact_range
			and player.flashlightView.visible
			and not player_searching
			and items > 0):
		player.in_range(self)
	else:
		player.out_range(self)

func interact(player:CharacterBody3D):
	"""Player calls this when an interaction needs to happen"""
	if (player.global_position.distance_squared_to(global_position) > interact_range 
			or player.spectralView.visible
			or player_searching
			or items < 1):
		return
	if animator.has_animation("animation_" + furniture_type + "_search"):
		animator.play("animation_" + furniture_type + "_search")
		player_searching = player

func interaction_complete(animation_name:String):
	"""Called when an animation, usually the search is complete"""
	if not (animation_name.ends_with("search") and player_searching):
		return
	items -= 1
	player_searching.draw_item()
	player_searching = null
