extends VBoxContainer

@onready var Injuries_label: Label = $Injuries_Label

func _on_game_gaze_changed(amount: int) -> void: ## Gets updates from game.gd and updates the gaze amount accordingly. 
	Injuries_label.text = str(amount) + " gaze"
		
