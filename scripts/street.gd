extends Control

signal person_clicked ## Creates a signal that indicates whenever a person is clicked. 

@export var person_scene: PackedScene ## Exports person scene for easy changing from the inspector later on. 
@export var spawn_interval := 0.9 ## Ditto. 
@export var clickable_chance := 0.15 ## Ditto. 
@export var horizon_ratio := 0.20 ## Ditto. 

var _timer := 0.0 ## Declares a timer variable for later. 

func _process(delta: float) -> void:
	_timer += delta
	if _timer >= spawn_interval:
		_timer = 0.0
		_spawn_person()

func _spawn_person() -> void:
	var p = person_scene.instantiate()
	add_child(p)
	p.setup(randf(), randf() < clickable_chance, size, horizon_ratio)
	p.clicked.connect(func(): person_clicked.emit())
