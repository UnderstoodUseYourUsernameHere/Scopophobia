class_name ChaseMinigame
extends Control

@export_range(80.0, 500.0, 10.0) var flee_speed: float = 240.0
@export_range(2.0, 15.0, 0.5) var round_seconds: float = 6.0
@export_range(12.0, 80.0, 2.0) var catch_radius: float = 36.0
@export_range(1.0, 20.0, 1.0) var bonus_multiplier: float = 5.0

@onready var arena: Panel = $CenterContainer/Card/Vbox/Arena
@onready var runner: TextureRect = $CenterContainer/Card/Vbox/Arena/Runner
@onready var status_label: Label = $CenterContainer/Card/Vbox/Status
@onready var instructions_label: Label = $CenterContainer/Card/Vbox/Instructions
@onready var timer_bar: ProgressBar = $CenterContainer/Card/Vbox/TimerBar
@onready var start_button: Button = $CenterContainer/Card/Vbox/StartButton

var _eye_texture: Texture2D
var _finished: bool = false
var _active: bool = false
var _runner_placed: bool = false
var _elapsed: float = 0.0
var _speed_boost: float = 0.0

func setup(person_texture: Texture2D, eye_texture: Texture2D) -> void:
	if person_texture == null:
		push_error("ChaseMinigame recieved a person with no texture!")
		return
	
	runner.texture = person_texture
	runner.size = Vector2(48.0, 64.0)
	status_label.text = "Catch them! Click when your cursor is close!"
	_elapsed = 0.0
	_runner_placed = false
	_eye_texture = eye_texture
	_active = false
	_finished = false
	
	instructions_label.text = (
		"Move the eye cursor towards the runner, they flee from you!"
		 + "Click when close enough to catch them before time runs out. \n\n" 
		 + "Catching adds %.0fx your normal click value. Them escaping has no penalty."
		 + "You still get your normal click reward after!"
	) % bonus_multiplier
	arena.hide()
	timer_bar.value = 100.0
	timer_bar.hide()
	status_label.text = "Ready?"
	start_button.text = "Begin Chase!"
	start_button.show()

func _on_start_button_pressed() -> void:
	if _finished:
		_close()
		return
	
	instructions_label.hide()
	start_button.hide()
	arena.show()
	timer_bar.show()
	Audio.play("ChaseStart")
	
	_elapsed = 0.0
	_runner_placed = false
	_active = true
	_speed_boost = minf(GameState.chase_streak * 12.0, 120.0)
	
	if _eye_texture != null:
		var eye_size: Vector2i = _eye_texture.get_size()
		var hotspot := Vector2(eye_size.x * 0.5, eye_size.y * 0.5)
		Input.set_custom_mouse_cursor(_eye_texture, Input.CURSOR_ARROW, hotspot)

func _ready() -> void:
	start_button.pressed.connect(_on_start_button_pressed)

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
	var distance_to_cursor: float = away.length()
	
	if away.length_squared() < 0.001:
		away = Vector2.RIGHT
	
	var progress: float = clampf(_elapsed / round_seconds, 0.0, 1.0)
	var move_speed: float = (flee_speed + _speed_boost) * lerpf(0.75, 1.4, progress)
	
	# Makes them panic when the eye gets close!
	if distance_to_cursor < 110.0:
		move_speed *= 1.25
	
	var direction: Vector2 = away.normalized()
	var max_x: float = maxf(arena.size.x - runner.size.x, 0.0)
	var max_y: float = maxf(arena.size.y - runner.size.y, 0.0)
	var next_position: Vector2 = runner.position + direction * move_speed * delta
	
	#Prevents sticking on the arena walls, maybe?
	if next_position.x < 0.0 or next_position.x > max_x:
		direction.x = -direction.x
	if next_position.y < 0.0 or next_position.y > max_y:
		direction.y = -direction.y
	
	next_position = runner.position + direction.normalized() * move_speed * delta
	runner.position = Vector2(
		clampf(next_position.x, 0.0, max_x),
		clampf(next_position.y, 0.0, max_y)
	)
	
	var time_left: float = max(round_seconds - _elapsed, 0.0)
	timer_bar.value = 100.0 * time_left / round_seconds
	status_label.text = "Click when close to catch them - %.1f sec" % time_left

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
		GameState.chase_streak += 1
		GameState.chases_won += 1
		var streak_mult: float = 1.0 + 0.25 * float(GameState.chase_streak - 1)
		var bonus: float = GameState.amount_per_click * bonus_multiplier * streak_mult
		GameState.add_gaze(bonus)
		Audio.stop("ChaseStart")
		Audio.play("Catch")
		status_label.text = "Caught! +%s Gaze (streak x%d)" % [
			GameState.format_number(bonus), GameState.chase_streak
		]
	else:
		GameState.chase_streak = 0
		GameState.chases_failed += 1
		Audio.play("Escape")
		status_label.text = "They escaped your gaze!"
	
	_finished = true
	start_button.text = "Continue"
	start_button.show()

func _close() -> void:
	get_tree().paused = false
	queue_free()

func _exit_tree() -> void:
	Input.set_custom_mouse_cursor(null)
	if get_tree() != null:
		get_tree().paused = false
