extends TextureButton

signal clicked ## Creates a signal, clicked.

var speed := 0.0 ## Declaring a variable, speed. 

func setup(depth: float, clickable: bool, area: Vector2, horizon_ratio: float) -> void:
	var tex_size := texture_normal.get_size() / 2  ## Size of the people, halved looks better. 
	var s: float = lerp(0.2, 0.8, depth) ## Scale and depth variable. 
	scale = Vector2(s, s)
	z_index = int(depth * 100)  ## Nearby people drawn on top.
	
	var dir := 1 if randf() < 0.5 else -1 ## Rolls the dice, 50/50 to spawn the sprite either looking to the right, or the left. 
	speed = lerp(40.0, 120.0, depth) * dir ## Interpolates linearly(lerp) and picks a speed between 40 and 120 based on their depth, closer sprites move faster, further sprites move slower. 
	flip_h = dir == -1 ## Sets the sprites flip property to try if dir is -1, false otherwise, this is to prevent the sprites from spawning in looking the wrong way. 
	
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
