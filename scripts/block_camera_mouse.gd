class_name BlockCameraMouseRect extends ColorRect

func is_mouse_inside() -> bool:
	var m:Vector2 = get_local_mouse_position()
	return m.x > 0 && m.x < size.x && m.y > 0 && m.y < size.y
