extends Control

var gaze = 0 ## Amount of gaze(Base currency), as a variable. 
var amount_per_click = 1 ## Self explanatory, amount of gaze you get per click.

signal gaze_changed ## Signal whenever the amount of gaze changes. 

func _on_clickbutton_button_down() -> void:
	print("Clicked!")
	gaze += amount_per_click ## Increases gaze by the variable amount_per_click.
	emit_signal ("gaze_changed", gaze)
