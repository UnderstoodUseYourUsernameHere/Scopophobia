class_name SettingsMenu
extends Control

signal closed

@onready var music_slider: HSlider = $CenterContainer/Panel/VBoxContainer/MusicSlider
@onready var sfx_slider: HSlider = $CenterContainer/Panel/VBoxContainer/SFXSlider
@onready var close_button: Button = $CenterContainer/Panel/VBoxContainer/CloseButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	hide()
	
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	close_button.pressed.connect(_close_menu)
	
func open_menu() -> void:
	music_slider.set_value_no_signal(Audio.get_bus_volume("Music"))
	sfx_slider.set_value_no_signal(Audio.get_bus_volume("SFX"))
	show()

func _on_music_changed(value: float) -> void:
	Audio.set_bus_volume("Music", value)

func _on_sfx_changed(value: float) -> void:
	Audio.set_bus_volume("SFX", value)

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
