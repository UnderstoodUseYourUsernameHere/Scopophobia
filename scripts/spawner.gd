extends Node2D

@export var target_scene: PackedScene = preload("res://Scenes/new_area_2d.tscn")
@export var spawn_interval_min: float = 0.5
@export var spawn_interval_max: float = 2.0
@export var speed_min: float = 100.0
@export var speed_max: float = 300.0

var timer: Timer

func _ready() -> void:
	timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	_queue_next_spawn()

func _queue_next_spawn() -> void:
	timer.wait_time = randf_range(spawn_interval_min, spawn_interval_max)
	timer.start()

func _on_timer_timeout() -> void:
	_spawn_target()
	_queue_next_spawn()

func _spawn_target() -> void:
	var target = target_scene.instantiate()
	var play_height = get_viewport_rect().size.y
	target.position = Vector2(-50, randf_range(50, play_height - 50))
	target.speed = randf_range(speed_min, speed_max)
	add_child(target)
	target.target_clicked.connect(_on_target_clicked)

func _on_target_clicked(target: Area2D) -> void:
	var game = get_owner()
	game.add_gaze(target.value)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
