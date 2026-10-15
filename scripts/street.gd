extends Control

signal person_clicked

@export var person_scene: PackedScene
@export var spawn_interval := 0.4
@export var clickable_chance := 0.15
@export var horizon_ratio := 0.35

var _timer := 0.0

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
