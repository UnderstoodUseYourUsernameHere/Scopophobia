extends Control

var gaze = 0
var amount_per_click = 1 

func _on_clickbutton_button_down() -> void:
	gaze += amount_per_click
	print(gaze)
