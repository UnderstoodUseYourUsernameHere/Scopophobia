class_name Person
extends TextureButton

signal clicked(person: Person)

const EDGE_MARGIN: float = 60.0
const CLICKABLE_Z_BOOST: int = 600

@onready var street := get_parent() as Control

var speed: float = 0.0

var is_clickable: bool = false
var _was_clicked: bool = false
var _despawn_margin: float = 100.0

func _ready() -> void:
	add_to_group("people")

func setup(
	y_ratio: float,
	person_scale: float,
	walk_speed: float,
	going_left: bool,
	clickable: bool,
	depth: float,
	area: Vector2
) -> void:
	if texture_normal == null:
		push_error("Person has no normal texture!")
		return
		
	is_clickable = clickable
	
	var visual_size: Vector2 = texture_normal.get_size() * person_scale
	scale = Vector2(person_scale, person_scale)
	_despawn_margin = visual_size.x + EDGE_MARGIN
	
	speed = -walk_speed if going_left else walk_speed
	flip_h = going_left
	
	var feet_y: float = area.y * y_ratio
	var start_x: float = area.x + EDGE_MARGIN if going_left else - _despawn_margin
	position = Vector2(start_x, feet_y - visual_size.y)
	
	var depth_z: int = int(depth * 100)
	if clickable:
		z_index = depth_z + CLICKABLE_Z_BOOST
		mouse_filter = Control.MOUSE_FILTER_STOP
		pressed.connect(_on_pressed)
	else:
		z_index = depth_z
		modulate = Color(0.08, 0.08, 0.1)
		mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(delta: float) -> void:
	position.x += speed  * delta
	
	if street == null:
		return
	if position.x > street.size.x + _despawn_margin or position.x < -_despawn_margin:
		queue_free()

func _on_pressed() -> void:
	if _was_clicked:
		return
	_was_clicked = true
	
	disabled = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	clicked.emit(self)
	queue_free()
