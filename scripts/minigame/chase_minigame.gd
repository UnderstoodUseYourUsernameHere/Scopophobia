class_name ChaseMinigame
extends Control

@export_range(80.0, 500.0, 10.0) var flee_speed: float = 240.0
@export_range(2.0, 15.0, 0.5) var round_seconds: float = 6.0
@export_range(12.0, 80.0, 2.0) var catch_radius: float = 36.0
@export_range(1.0, 20.0, 1.0) var bonus_multiplier: float = 5.0

@onready var arena: Label = $CenterContainer/Card/Vbox/Arena
@onready var runner: TextureRect = $CenterContainer/Card/Vbox/Arena/Runner
@onready var status_label: Label = $CenterContainer/Card/Vbox/Status

var _active: bool = false
var _runner_placed: bool = false
var _elapsed: float = 0.0

func setup(person_texture: Texture2D, eye_texture: Texture2D) -> void:
	if person_texture == null:
		push_error("ChaseMinigame recieved a person with no texture!")
		return
	
	runner.texture = person_texture
	runner.size = Vector2(48.0, 64.0)
	status_label.text = "Catch them! Click when your cursor is close!"
	_elapsed = 0.0
	_runner_placed = false
	_active = true
	
	if eye_texture != null:
		var eye_size: Vector2i = eye_texture.get_size()
		var hotspot: Vector2 = Vector2(eye_size.x * 0.5, eye_size.y * 0.5)
		Input.set_custom_mouse_cursor(eye_texture, Input.CURSOR_ARROW, hotspot)

func _process(delta: float) -> void:
	if not _active:
		return
	
	if not _runner_placed:
		_place_runner()
		if not _runner_placed:
			return
	
	_elapsed += delta
	if _elapsed >= round_seconds:
		_finish(false)
		return
	
	var mouse_position: Vector2 = arena.get_local_mouse_position()
	var runner_center: Vector2 = runner.position + runner.size * 0.5
	var away: Vector2 = runner_center - mouse_position
	
	if away.length_squared() < 0.001:
		away = Vector2.RIGHT
	
	var next_position: Vector2 = (
		runner.position + away.normalized() * flee_speed * delta
	)
	var max_x: float = maxf(arena.size.x - runner.size.x, 0.0)
	var max_y: float = maxf(arena.size.y - runner.size.y, 0.0)
	
	runner.position = Vector2(
	 clampf(next_position.x, 0.0, max_x),
	 clampf(next_position.y, 0.0, max_y)
	)
	
	status_label.text = "Click when close - %.1f sec" % maxf(round_seconds - _elapsed, 0.0)

func _place_runner() -> void:
	if arena.size.x < runner.size.x or arena.size.y < runner.size.y: 
		return
	
	var max_x: float = arena.size.x - runner.size.x
	var max_y: float = arena.size.y - runner.size.y
	
	runner.position = Vector2(
		randf_range(0.0, max_x),
		randf_range(0.0, max_y)
	)
	_runner_placed = true 

func _input(event: InputEvent) -> void:
	if not _active:
		return
	
	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		if key_event.pressed and not key_event.echo and key_event.keycode == KEY_ESCAPE:
			_finish(false)
			get_viewport().set_input_as_handled()
		return
	
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if not mouse_event.pressed or mouse_event.button_index != MOUSE_BUTTON_LEFT:
			return
		 
		if _runner_placed:
			var mouse_position: Vector2 = arena.get_local_mouse_position()
			var runner_center: Vector2 = runner.position + runner.size * 0.5
			if mouse_position.distance_to(runner_center) <= catch_radius:
				_finish(true)
		get_viewport().set_input_as_handled()

func _finish(caught: bool) -> void:
	if not _active:
		return
	
	_active = false
	Input.set_custom_mouse_cursor(null)
	
	if caught:
		var bonus: float = GameState.amount_per_click * bonus_multiplier
		GameState.add_gaze(bonus)
		status_label.text = "Caught! +%s Gaze" % GameState.format_number(bonus)
	else:
		status_label.text = "They escaped your gaze!"
	get_tree().create_timer(0.8).timeout.connect(_close)

func _close() -> void:
	queue_free()

func _exit_tree() -> void:
	Input.set_custom_mouse_cursor(null)
