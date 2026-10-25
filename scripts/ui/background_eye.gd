class_name BackgroundEye
extends Control

@export var pupil: TextureRect
@export var blink_color: Color = Color("0b0b14")

@export_group("Movement")
@export_range(0.0, 400.0, 1.0) var max_pupil_offset: float = 90.0
@export_range(1.0, 20.0, 0.5) var follow_speed: float = 5.0

@export_group("Glancing")
@export_range(1.0, 60.0, 0.5) var glance_min_delay: float = 6.0
@export_range(1.0, 60.0, 0.5) var glance_max_delay: float = 14.0
@export_range(0.5, 8.0, 0.1) var glance_duration: float = 2.5

var _street: Street
var _glance_target: Person
var _glance_time_left: float = 0.0
var _time_until_glance: float = 0.0
var 

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 0
	_street = get_parent() as Street
	_reset_glance_timer()

func _is_chase_ready() -> bool:
	var root := get_tree().current_scene
	if root != null and root.has_method("is_chase_ready"):
		return root.is_chase_ready()
	return false

func _update_glance(delta: float) -> void: 
	if _glance_target != null:
		_glance_time_left -= delta
		var lost: bool = (
			not is_instance_valid(_glance_target)
			or _glance_target.is_queued_for_deletion()
			or not _is_chase_ready()
		)
		if _glance_time_left <= 0.0 or lost:
			_glance_target = null
			_reset_glance_timer()
		return
	
	_time_until_glance -= delta
	if _time_until_glance > 0.0:
			return
	
	if not _is_chase_ready():
		_reset_glance_timer()
		return
	
	_glance_target = _pick_marked_person()
	if _glance_target == null:
		_reset_glance_timer()
	else:
		_glance_time_left = glance_duration


func _process(delta: float) -> void:
	if pupil == null:
		return
	
	_update_glance(delta)
	
	var eye_center: Vector2 = global_position + size * 0.5
	var desired_offset: Vector2 = (
		(_current_target_point() - eye_center).limit_length(max_pupil_offset)
	)
	var rest_position: Vector2 = size * 0.5 - pupil.size * 0.5
	
	var weight: float = 1.0 - exp(-follow_speed * delta)
	pupil.position = pupil.position.lerp(rest_position + desired_offset, weight) ## Should smooth independent of framerate. 
	
func _current_target_point() -> Vector2: 
	if is_instance_valid(_glance_target) and not _glance_target.is_queued_for_deletion():
		var body: Vector2 = _glance_target.size * _glance_target.scale
		return _glance_target.global_position + body * 0.5
	return get_global_mouse_position()

func _pick_marked_person() -> Person:
	if _street == null:
		return null
	
	var marked: Array[Person] = []
	for child in _street.get_children():
		var eye_icon := child as UpgradeIcon
		if eye_icon == null:
			continue
		var candidate := eye_icon.get_target()
		if candidate != null and eye_icon.has_method("is_minigame_ready") and eye_icon.is_minigame_ready():
			marked.append(candidate)
	
	if marked.is_empty():
		return null
	return marked.pick_random()

func _reset_glance_timer() -> void:
	_time_until_glance = randf_range(glance_min_delay, glance_max_delay)
	
