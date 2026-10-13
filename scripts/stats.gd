extends VBoxContainer

@onready var gaze_label: Label = $gazeLabel

func _on_game_gaze_changed(amount: int) -> void:
	gaze_label.text = str(amount) + " gaze"
	
