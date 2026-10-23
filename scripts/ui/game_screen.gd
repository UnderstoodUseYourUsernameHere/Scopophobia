extends Control

@onready var street: Street = %Street
@onready var save_timer: Timer = %SaveTimer
@export var upgrade_icon_scene: PackedScene
@export var clicked_text_scene: PackedScene
@export var chase_minigame_scene: PackedScene
@export var max_upgrade_icons: int = 4
@onready var reset_button: Button = %ResetButton


func _ready() -> void:
	reset_button.pressed.connect(_on_reset_pressed)
	street.person_clicked.connect(_on_person_clicked)
	GameState.upgrade_purchased.connect(_on_upgrade_purchased)
	save_timer.timeout.connect(_on_save_timer_timeout)

func _on_reset_pressed() -> void:
	GameState.reset_data()
	get_tree().reload_current_scene()

func _on_person_clicked(person: Person) -> void:
	var gained : float = GameState.amount_per_click
	GameState.click_person()
	_spawn_clicked_text("+%s" % GameState.format_number(gained), get_global_mouse_position())
	var eye: UpgradeIcon = _find_eye_for(person)
	if eye != null:
		_open_chase(person, eye.texture)

func _find_eye_for(person: Person) -> UpgradeIcon:
	for child in street.get_children():
		var eye: UpgradeIcon = child as UpgradeIcon
		if eye != null and eye.is_tracking_candidate(person):
			return eye
	return null

func _open_chase(person: Person, eye_texture: Texture2D) -> void:
	if chase_minigame_scene == null:
		push_error("Gamescreen has no chase minigame scene assigned!")
		return
	
	var minigame: ChaseMinigame = chase_minigame_scene.instantiate() as ChaseMinigame
	if minigame == null:
		push_error("Chase minigame scene root needs chase_minigame.gd!")
		return
	
	add_child(minigame)
	minigame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	minigame.setup(person.texture_normal, eye_texture)

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
