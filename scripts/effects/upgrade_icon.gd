class_name UpgradeIcon
extends TextureRect

@export var offset: Vector2 = Vector2(0, -40)

var _target: Person

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 1000
	_pick_new_target()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_instance_valid(_target) or _target.is_queued_for_deletion():
		_pick_new_target()
	
	if not is_instance_valid(_target):
		visible = false
		return
	
	visible = true
	_follow_target()
 
func _pick_new_target() -> void:
	var candidates: Array = get_tree().get_nodes_in_group("people").filter(
		func(p): return p is Person and p.is_clickable and not p.is_queued_for_deletion()
	)
	
	if candidates.is_empty():
		_target = null
		return
	
	_target = candidates.pick_random() as Person

func _follow_target() -> void:
	var body_size := _target.texture_normal.get_size() * _target.scale
	var head := _target.position + Vector2(body_size.x * 0.5, 0.0)
	position = head - size * 0.5 + offset

func get_target() -> Person:
	if is_instance_valid(_target) and not _target.is_queued_for_deletion():
		return _target
	return null

func is_tracking_candidate(candidate: Person) -> bool:
	return is_instance_valid(_target) and _target == candidate
