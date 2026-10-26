class_name SettingsMenu
extends Control

signal closed
signal reset_requested

@onready var music_slider: HSlider = %MusicSlider
@onready var music_value: Label = %MusicValue
@onready var music_mute: Button = %MusicMute

@onready var sfx_slider: HSlider = $%SFXSlider
@onready var sfx_value: Label = %SFXValue
@onready var sfx_mute: Button = %SFXMute

@onready var close_button: Button = $%CloseButton
@onready var reset_button: Button = %ResetButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	hide()
	
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	close_button.pressed.connect(_close_menu)
	music_mute.pressed.connect(_toggle_music_mute)
	sfx_mute.pressed.connect(_toggle_sfx_mute)
	reset_button.pressed.connect(reset_requested.emit)
	
func open_menu() -> void:
	music_slider.set_value_no_signal(Audio.get_bus_volume("Music"))
	sfx_slider.set_value_no_signal(Audio.get_bus_volume("SFX"))
	Audio.play("Click")
	_refresh_labels()
	show()

func _on_music_changed(value: float) -> void:
	Audio.set_bus_volume("Music", value)
	_refresh_labels()

func _on_sfx_changed(value: float) -> void:
	Audio.set_bus_volume("SFX", value)
	_refresh_labels()

func save_settings() -> void:
	Audio.save_volume_settings(music_slider.value, sfx_slider.value)

func _close_menu() -> void:
	save_settings()
	closed.emit()

func _unhandled_input(event: InputEvent) -> void:
	var key_event := event as InputEventKey
	if key_event == null or not key_event.pressed or key_event.echo:
		return
	if key_event.keycode == KEY_ESCAPE:
		_close_menu()
		get_viewport().set_input_as_handled()
	elif key_event.keycode == KEY_M:
		_toggle_music_mute()
		get_viewport().set_input_as_handled()
	elif key_event.keycode == KEY_N:
		_toggle_sfx_mute()
		get_viewport().set_input_as_handled()

func _toggle_music_mute() -> void:
	Audio.toggle_mute("Music")
	_refresh_labels()

func _toggle_sfx_mute() -> void:
	Audio.toggle_mute("SFX")
	_refresh_labels()

func _refresh_labels() -> void:
	music_value.text = "%d%%" % roundi(music_slider.value * 100.0)
	sfx_value.text = "%d%%" % roundi(sfx_slider.value * 100.0)
	var music_muted := AudioServer.is_bus_mute(AudioServer.get_bus_index("Music"))
	var sfx_muted := AudioServer.is_bus_mute(AudioServer.get_bus_index("SFX"))
	music_mute.text = "Unmute" if music_muted else "Mute"
	sfx_mute.text = "Unmute" if sfx_muted else "Mute"
