extends Control

@onready var street: Street = %Street
@onready var save_timer: Timer = %SaveTimer
@onready var reset_button: Button = %ResetButton
@export var upgrade_icon_scene: PackedScene
@export var clicked_text_scene: PackedScene
@export var chase_minigame_scene: PackedScene
@export var max_upgrade_icons: int = 4
@export_range(0.0, 120.0, 1.0) var chase_cooldown_seconds: float = 20.0 
var _chase_cooldown_remaining: float = 0.0

func _ready() -> void:
	reset_button.pressed.connect(_on_reset_pressed)
	street.person_clicked.connect(_on_person_clicked)
	GameState.upgrade_purchased.connect(_on_upgrade_purchased)
	save_timer.timeout.connect(_on_save_timer_timeout)
	_show_offline_gain()

func _show_offline_gain() -> void:
	if GameState.pending_offline_gain < 1.0:
		return
	var dialog := AcceptDialog.new()
	dialog.title = "Welcome back bud!"
	dialog.dialog_text = "The eye kept watching. \n+%s Gaze earned while away." % \
	GameState.format_number(GameState.pending_offline_gain)
	add_child(dialog)
	dialog.popup_centered()
	GameState.pending_offline_gain = 0.0

func _on_reset_pressed() -> void:
	GameState.reset_data()
	get_tree().reload_current_scene()

func _on_person_clicked(person: Person) -> void:
	var gained : float = GameState.amount_per_click
	GameState.click_person()
	_spawn_clicked_text("+%s" % GameState.format_number(gained), get_global_mouse_position())
	var eye: UpgradeIcon = _find_eye_for(person)
	if eye != null and _chase_cooldown_remaining <= 0.0:
		_open_chase(person, eye.texture)

func _process(delta: float) -> void:
	_chase_cooldown_remaining = maxf(_chase_cooldown_remaining - delta, 0.0)

func _find_eye_for(person: Person) -> UpgradeIcon:
	for child in street.get_children():
		var eye: UpgradeIcon = child as UpgradeIcon
		if eye != null and eye.is_tracking_candidate(person):
			return eye
	return null

func is_chase_ready() -> bool:
	return _chase_cooldown_remaining <= 0.0

func _open_chase(person: Person, eye_texture: Texture2D) -> void:
	if chase_minigame_scene == null:
		push_error("Gamescreen has no minigame scene assigned!")
		return
	
	var minigame: ChaseMinigame = chase_minigame_scene.instantiate() as ChaseMinigame
	if minigame == null:
		push_error("Chase minigame scene root needs chase_minigame.gd!")
		return
	
	minigame.process_mode = Node.PROCESS_MODE_ALWAYS
	minigame.z_as_relative = false
	minigame.z_index = 4096
	minigame.mouse_filter = Control.MOUSE_FILTER_STOP
	minigame.modulate.a = 0.0
	
	add_child(minigame)
	minigame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	minigame.setup(person.texture_normal, eye_texture)
	
	var fade: Tween = minigame.create_tween()
	fade.tween_property(minigame, "modulate:a", 1.0, 0.2)
	
	_chase_cooldown_remaining = chase_cooldown_seconds
	get_tree().paused = true 

func _on_upgrade_purchased(data: UpgradeData) -> void:
	if data == null or data.icon == null:
		return
	var active_icons: int = 0
	for child in street.get_children():
		if child is UpgradeIcon:
			active_icons += 1
	if active_icons >= max_upgrade_icons:
		return
	if upgrade_icon_scene == null:	
		return
	var icon := upgrade_icon_scene.instantiate() as UpgradeIcon
	if icon == null:
		return
	icon.texture = data.icon
	street.add_child(icon)

func _spawn_clicked_text(message: String, at_global: Vector2) -> void:
	var label := clicked_text_scene.instantiate() as ClickedText
	street.add_child(label)
	label.setup(message, at_global)

func _on_save_timer_timeout() -> void:
	GameState.save_data()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		GameState.save_data()
