extends TextureButton

signal clicked

var speed := 0.0 

func setup(depth: float, clickable: bool, area: Vector2, horizon_ratio: float) -> void:
	var tex_size := texture_normal.get_size()
	var s: float = lerp(0.4, 1.0, depth)
	scale = Vector2(s, s)
	z_index = int(depth * 100)  ## Near people drawn on top.
	
	var dir := 1 if randf() < 0.5 else -1
	speed = lerp(40.0, 120.0, depth) * dir
	flip_h = dir == -1
	
	var y: float = lerp(area.y * horizon_ratio, area.y - tex_size.y * s, depth)
	var x: float = -tex_size.x * s if dir == 1 else area.x
	position = Vector2(x, y)
	
	if clickable:
		pressed.connect(_on_pressed)
	else: 
		modulate = Color(0.08, 0.08, 0.1)
		mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(delta: float) -> void:
	position.x += speed * delta
	var w: float = get_parent().size.x
	if position.x > w + 100 or position.x < -300:
		queue_free()

func _on_pressed() -> void:
	clicked.emit()
	queue_free()
