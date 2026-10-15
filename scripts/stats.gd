extends VBoxContainer

@onready var Gaze_Label: Label = $Gaze_Label

func _on_game_gaze_changed(amount: int) -> void: ## Gets updates from game.gd and updates the gaze amount accordingly. 
	Gaze_Label.text = str(amount) + " gaze"
