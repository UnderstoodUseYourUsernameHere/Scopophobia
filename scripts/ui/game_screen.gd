extends Control

@onready var street: Street = %Street
@onready var save_timer: Timer = %SaveTimer

func _ready() -> void:
	street.person_clicked.connect(_on_person_clicked)
	save_timer.timeout.connect(_on_save_timer_timeout)

func _on_person_clicked() -> void:
	GameState.click_person()

func _on_save_timer_timeout() -> void:
	GameState.save_data()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		GameState.save_data()
