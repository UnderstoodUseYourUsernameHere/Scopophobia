extends Node
## To use the audio anywhere since its an autoload just use Audio.play("Click") Or any of the other effects.

const SETTINGS_PATH := "user://audio_settings.cfg"

@export_range(0.0,0.5, 0.1) var sfx_pitch_jitter: float = 0.08

func play(sound_name: StringName) -> void:
	var player := get_node_or_null(NodePath(sound_name)) as AudioStreamPlayer
	if player == null:
		push_warning("Audio: no player named '%s'" % sound_name)
		return
	if player.stream == null:
		return
	player.pitch_scale = 1.0 + randf_range(-sfx_pitch_jitter, sfx_pitch_jitter)
	player.play()

func stop(sound_name: StringName) -> void:
	var player := get_node_or_null(NodePath(sound_name)) as AudioStreamPlayer
	if player == null:
		return
	player.stop()

func set_bus_volume(bus_name: String, linear: float) -> void:
	var index := AudioServer.get_bus_index(bus_name)
	if index == -1:
		return
	AudioServer.set_bus_volume_db(index, linear_to_db(clampf(linear, 0.0001, 1.0)))
	AudioServer.set_bus_mute(index, linear <= 0.0001)

func _ready() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return
	
	set_bus_volume("Music", float(config.get_value("audio", "music", 1.0)))
	set_bus_volume("SFX", float(config.get_value("audio", "sfx", 1.0)))

func get_bus_volume(bus_name: String) -> float:
	var index: int = AudioServer.get_bus_index(bus_name)
	if index == -1:
		return 1.0
	if AudioServer.is_bus_mute(index):
		return 0.0
	return clampf(db_to_linear(AudioServer.get_bus_volume_db(index)), 0.0, 1.0)

func save_volume_settings(music: float, sfx: float) -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "music", music)
	config.set_value("audio", "sfx", sfx)
	var error: Error = config.save(SETTINGS_PATH)
	if error != OK:
		push_warning("Could not save audio preferences!")

func toggle_master_mute() -> void:
	var index: int = AudioServer.get_bus_index("Master")
	if index == -1:
		return
	AudioServer.set_bus_mute(index, not AudioServer.is_bus_mute(index))

func toggle_mute(bus_name: String) -> void:
	var index: int = AudioServer.get_bus_index(bus_name)
	if index == -1:
		return
	AudioServer.set_bus_mute(index, not AudioServer.is_bus_mute(index))
