extends VBoxContainer

@onready var gaze_label: Label = $GazeLabel ## Defers initialization of gaze_label until the node and its children have fully entered the scene and are ready.
@onready var gps_label: Label = $GpsLabel ## Defers initialization of gps_label until the node and its children have fully entered the scene and are ready. 

func _ready() -> void:
	GameState.gaze_changed.connect(_on_gaze_changed)
	
	_on_gaze_changed(
		GameState.gaze,
		GameState.gaze_per_second
	)

func _on_gaze_changed(amount: float, per_second: float) -> void:
	gaze_label.text = "%s gaze" % GameState.format_number(amount)
	gps_label.text = "%.1f gaze/sec" % per_second
