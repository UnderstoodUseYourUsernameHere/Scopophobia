extends VBoxContainer

@onready var gaze_label: Label = $GazeLabel ## Defers initialization of gaze_label until the node and its children have fully entered the scene and are ready.
@onready var gps_label: Label = $GpsLabel ## Defers initialization of gps_label until the node and its children have fully entered the scene and are ready. 

func _on_game_gaze_changed(amount: int, per_second: float) -> void: ## Gets updates from game.gd and updates the gaze amount accordingly. 
	if gaze_label == null or gps_label == null: ## If gaze_label and gps_label are null, return, prevents game crashing. 
		return
	gaze_label.text = "%d gaze" % amount ## Updates gaze_label to a decimal integer of gaze amount
	gps_label.text = "%.1f gaze/sec" % per_second ## Updates gps_label to float format to 1 decimal place, per second. 
