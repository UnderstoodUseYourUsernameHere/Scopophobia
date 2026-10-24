class_name Street
extends Control

signal person_clicked(person: Person)

@export var person_scene: PackedScene
@export var lanes: Array[LaneData] = []
@export var spawn_interval: float = 1.2
@export var max_people: int = 12

var _time_until_spawn: float = 0.0

func _ready() -> void:
	if person_scene == null:
		push_error("Street doesnt have a person scene assigned buddy!!!")
		set_process(false)
		return
	if lanes.is_empty():
		push_error("Street has no lanes assigned! Make sure to add lane resources!")
		set_process(false)

func _process(delta: float) -> void:
	_time_until_spawn += delta 
	if _time_until_spawn < spawn_interval:
		return
	
	_time_until_spawn -= spawn_interval
	_spawn_person()

func _spawn_person() -> void:
	if get_tree().get_node_count_in_group("people") >= max_people:
		return
	
	var lane := _pick_lane()
	if lane == null:
		return
	

	var person := person_scene.instantiate() as Person
	if person == null:
		push_error("Person scene is missing the root person.gd!")
		return
	add_child(person)
	person.clicked.connect(_on_person_clicked)
	person.setup(lane, randf() < lane.clickable_chance, size)

func _pick_lane() -> LaneData:
	var total: float = 0.0
	for lane in lanes:
		if lane != null:
			total += maxf(lane.spawn_weight, 0.0)
	if total <= 0.0:
		return null
	
	var roll: float = randf() * total
	for lane in lanes:
		if lane == null:
			continue
		roll -= maxf(lane.spawn_weight, 0.0)
		if roll <= 0.0:
			return lane
	return null

func _on_person_clicked(person: Person) -> void:
	person_clicked.emit(person)
