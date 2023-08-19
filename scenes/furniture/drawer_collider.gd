extends Area3D

var open: bool = false

func toggle():
	if !open:
		open = true
		$"../AnimationPlayer".seek(0)		
		$"../AnimationPlayer".play("animation_nightstand_search")
		await (get_tree().create_timer(1).timeout)
		$"../AnimationPlayer".pause()
	else:
		open = false
		$"../AnimationPlayer".seek(1)
		$"../AnimationPlayer".play("animation_nightstand_search")
		await (get_tree().create_timer(1).timeout)
		$"../AnimationPlayer".pause()
