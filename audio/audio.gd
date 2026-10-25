extends Node
## To use the audio anywhere since its an autoload just use Audio.play("Click") Or any of the other effects.

@export_range(0.0,0.5, 0.1) var sfx_pitch_jitter: float = 0.08

func play(sound_name: StringName) -> void:
	var player := get_node_or_null(NodePath(sound_name)) as AudioStreamPlayer
	if player == null:
		push_warning("Audio: no player named '%s'" % sound_name)
		return
	if player.stream == null:
		return
	player.pitch_scale = 1.0 + randf_range(-sfx_pitch_jitter, sfx_pitch_jitter)\
	player.play()

func set_bus_volume(bus_name: String, linear: float) -> void:
	var index := AudioServer.get_bus_index(bus_name)
	if index == -1:
		return
	AudioServer.set_bus_volume_db(index, linear_to_db(clampf(linear, 0.0001, 1.0)))
	AudioServer.set_bus_mute(index, linear <= 0.0001)
