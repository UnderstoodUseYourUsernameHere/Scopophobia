class_name Street
extends Control

signal person_clicked(person: Person)

@export var person_scene: PackedScene

@export_group("Spawning")
@export_range(0.2, 10.0, 0.1) var spawn_interval: float = 1.2
@export_range(1, 40, 1) var max_people: int = 12
@export_range(0.0, 1.0, 0.01) var clickable_chance: float = 0.2
@export_range(0.0, 1.0, 0.01) var leftward_chance: float = 0.5

@export_group("Spawn Band")
@export_range(0.0, 1.0, 0.01) var far_y_ratio: float = 0.55
@export_range(0.0, 1.0, 0.01) var near_y_ratio: float = 0.90

@export_group("Person Variation")
@export_range(0.05, 1.0, 0.01) var far_scale: float = 0.15
@export_range(0.05, 1.0, 0.01) var near_scale: float = 0.40
@export_range(10.0, 400.0, 1.0) var far_speed: float = 45.0
@export_range(10.0, 400.0, 1.0) var near_speed: float = 120.0
@export_range(0.0, 0.2, 0.01) var scale_jitter: float = 0.025
@export_range(0.0, 0.5, 0.01) var speed_variation: float = 0.15

@export_group("Optional Sprite Variants")
@export var person_textures: Array[Texture2D] = []


var _time_until_spawn: float = 0.0

func _ready() -> void:
	if person_scene == null:
		push_error("Street doesnt have a person scene assigned buddy!!!")
		set_process(false)
		return

func _process(delta: float) -> void:
	_time_until_spawn += delta 
	if _time_until_spawn < spawn_interval:
		return
	
	_time_until_spawn -= spawn_interval
	_spawn_person()

func _spawn_person() -> void:
	if get_tree().get_node_count_in_group("people") >= max_people:
		return
	
	var person := person_scene.instantiate() as Person
	if person == null:
		push_error("Person scene is missing the root person script!")
		return
	
	if not person_textures.is_empty():
		var chosen_texture: Texture2D = person_textures.pick_random()
		person.texture_normal = chosen_texture
	
	var depth: float = randf()
	var y_ratio: float = lerpf(far_y_ratio, near_y_ratio, depth)
	
	var person_scale: float = lerpf(far_scale, near_scale, depth)
	person_scale += randf_range(-scale_jitter, scale_jitter)
	person_scale = clampf(person_scale, 0.05, 1.0)
	
	var walk_speed: float = lerpf(far_speed, near_speed, depth)
	walk_speed *= randf_range(
		1.0 - speed_variation,
		1.0 + speed_variation
	)
	
	var going_left: bool = randf() < leftward_chance
	var clickable: bool = randf() < clickable_chance
	
	add_child(person)
	person.clicked.connect(_on_person_clicked)
	person.setup(
		y_ratio,
		person_scale,
		walk_speed,
		going_left,
		clickable,
		depth,
		size
	)

func _on_person_clicked(person: Person) -> void:
	person_clicked.emit(person)
