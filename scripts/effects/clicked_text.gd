class_name ClickedText
extends Label

func setup(message: String, at_global: Vector2) -> void:
	text = message
	global_position = at_global - Vector2(0, 20)

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 1100
	
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y - 60.0, 0.8)
	tween.tween_property(self, "modulate:a", 0.0, 0.8)
	tween.finished.connect(queue_free)
