extends TextureButton

@export var scale_speed: float = 0.1
@export var scale_target: float = 1.2

func on_mouse_entered():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(scale_target, scale_target), scale_speed)
	AudioPlayer.play_pop()

func on_mouse_exited():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, scale_speed)
