extends VBoxContainer

@onready var gaze_label: Label = $GazeLabel ## Defers initialization of gaze_label until the node and its children have fully entered the scene and are ready.
@onready var gps_label: Label = $GpsLabel ## Defers initialization of gps_label until the node and its children have fully entered the scene and are ready. 

var _details: Label

func _ready() -> void:
	_details = Label.new()
	add_child(_details)
	GameState.gaze_changed.connect(_on_gaze_changed)
	
	_on_gaze_changed(
		GameState.gaze,
		GameState.gaze_per_second
	)

func _on_gaze_changed(amount: float, per_second: float) -> void:
	gaze_label.text = "%s gaze" % GameState.format_number(amount)
	gps_label.text = "%.1f gaze/sec" % per_second
	_details.text = "Clicks: %d\nchases: %d won / %d lost\nStreak: x%d" % [
		GameState.total_clicks,
		GameState.chases_failed,
		GameState.chases_won,
		GameState.chase_streak,
	]
