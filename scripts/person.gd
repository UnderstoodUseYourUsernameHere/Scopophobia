class_name Person
extends TextureButton

@onready var street := get_parent() as Control

signal clicked 

var speed: float = 0.0 

func _ready() -> void:
	add_to_group("people")

func setup(
	depth: float,
	clickable: bool,
	area: Vector2,
	horizon_ratio: float
) -> void:
	if texture_normal == null:
		push_error("Person has no normal texturee bud!")
		return
	
	var texture_size := texture_normal.get_size() * 0.3
	var person_scale := lerpf(0.15, 0.6, depth)
	
	scale = Vector2(person_scale, person_scale)
	z_index = int(depth * 50)
	
	var direction := 1 if randf() < 0.5 else -1
	
	speed = lerpf(40.0, 120.0, depth) * direction # Nearby people move faster to create a sense of depth.
	flip_h = direction == -1
	
	var y := lerpf(
		area.y * horizon_ratio,
		area.y - texture_size.y * person_scale,
		depth
	)
	
	var x := -texture_size.x * person_scale if direction == 1 else area.x 
	position = Vector2(x, y)
	
	if clickable:
		pressed.connect(_on_pressed)
	else: 
		modulate = Color(0.08, 0.08, 0.1)
		mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(delta: float) -> void:
	position.x += speed * delta
	if street == null:
		return
	if position.x > street.size.x + 100.0 or position.x < -300.0:
		queue_free()

func _on_pressed() -> void:
	clicked.emit()
	queue_free()
