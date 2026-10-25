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
	var claimed_people: Array[Person] = []
	
	for child in get_parent().get_children():
		var other_icon := child as UpgradeIcon
		
		if other_icon == null or other_icon == self:
			continue
		
		var claimed_target := other_icon.get_target()
		
		if claimed_target != null:
			claimed_people.append(claimed_target)
		
	var available_people: Array[Person] = []
	
	for node in get_tree().get_nodes_in_group("people"):
		var candidate := node as Person
		
		if candidate == null:
			continue
		
		if candidate.is_queued_for_deletion():
			continue
		
		if candidate.mouse_filter != Control.MOUSE_FILTER_STOP:
			continue
		
		if candidate in claimed_people:
			continue
		
		available_people.append(candidate)
	
	if available_people.is_empty():
		_target = null
		return
	
	_target = available_people.pick_random()

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
