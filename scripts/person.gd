class_name Person
extends TextureButton

signal clicked(person: Person)

const EDGE_MARGIN: float = 60.0
const CLICKABLE_Z_BOOST: int = 600

@onready var street := get_parent() as Control

var speed: float = 0.0

var _was_clicked: bool = false
var _despawn_margin: float = 100.0

func _ready() -> void:
	add_to_group("people")

func setup(lane: LaneData, clickable: bool, area: Vector2) -> void:
	if texture_normal == null:
		push_error("Person has no normal texture!")
		return
	
	if lane == null:
		push_error("Person got a null lane!")
		return
	
	var texture_size: Vector2 = texture_normal.get_size()
	var visual_size: Vector2 = texture_size * lane.person_scale
	
	scale = Vector2(lane.person_scale, lane.person_scale)
	_despawn_margin = visual_size.x + EDGE_MARGIN
	
	var going_left: bool = randf() < lane.leftward_chance
	var direction: 	float = 1.0 if going_left else 1.0
	speed = lane.speed * direction
	flip_h = going_left
	
	var feet_y: float = area.y * lane.y_ratio
	var start_x: float = area.x + EDGE_MARGIN if going_left else -_despawn_margin
	position = Vector2(start_x, feet_y - visual_size.y)
	
	if clickable:
		z_index = lane.z_base + CLICKABLE_Z_BOOST
		modulate = lane.tint
		mouse_filter = Control.MOUSE_FILTER_STOP
		pressed.connect(_on_pressed)
	else:
		z_index = lane.z_base
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
