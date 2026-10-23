extends Control

@onready var street: Street = %Street
@onready var save_timer: Timer = %SaveTimer
@export var upgrade_icon_scene: PackedScene
@export var clicked_text_scene: PackedScene

func _ready() -> void:
	street.person_clicked.connect(_on_person_clicked)
	GameState.upgrade_purchased.connect(_on_upgrade_purchased)
	save_timer.timeout.connect(_on_save_timer_timeout)

func _on_person_clicked() -> void:
	var gained : float = GameState.amount_per_click
	GameState.click_person()
	_spawn_clicked_text("+%s" % GameState.format_number(gained), get_global_mouse_position())

func _on_upgrade_purchased() -> void:
	var data = UpgradeData
	if data.icon == null:
		return
	var icon := upgrade_icon_scene.instantiate() as UpgradeIcon
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
