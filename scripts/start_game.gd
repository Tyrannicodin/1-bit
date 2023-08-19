extends Button

func _ready():
	self.pressed.connect(self._button_pressed)

func _button_pressed():
	get_tree().change_scene_to_file("res://scenes/generation_test.tscn")
