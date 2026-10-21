class_name Street
extends Control

signal person_clicked

@export var person_scene: PackedScene
@export var spawn_interval: float = 0.9
@export_range(0.0, 1.0) var clickable_chance: float = 0.15
@export_range(0.0, 1.0) var horizon_ratio: float = 0.20

var _time_until_spawn: float = 0.0

func _ready() -> void:
	if person_scene == null:
		push_error("Street doesnt have a person scene assigned buddy!!!")
		set_process(false)

func _process(delta: float) -> void:
	_time_until_spawn += delta 
	
	if _time_until_spawn >= spawn_interval:
		_time_until_spawn -= spawn_interval
		_spawn_person()

func _spawn_person() -> void:
	var person := person_scene.instantiate() as Person
	
	if person == null:
		push_error("Aint no person.gd assigned to the person scene!")
		return
	
	add_child(person)
	
	person.setup(
		randf(),
		randf() < clickable_chance,
		size,
		horizon_ratio
	)
	person.clicked.connect(_on_person_clicked)


func _on_person_clicked() -> void:
	person_clicked.emit()
