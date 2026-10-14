extends Control

const save_path = "user://userdata.save" ## Saves a path for the save file.

var gaze = 0 ## Amount of gaze(base currency) as a variable.
var amount_per_click = 1 ## Amount of gaze you get per click.

signal gaze_changed(amount: int) ## Signal whenever the amount of gaze changes with the amount in an integer.

func _ready() -> void: ## Loads data and changes gaze to amount saved on game start.
	load_data()
	gaze_changed.emit(gaze)

func save_data() -> void: ## Save function, declares a variable, data, saved. Containing the amount of gaze currently.
	var data = {
		"gaze": gaze,
	}
	
	var file = FileAccess.open(save_path, FileAccess.WRITE) ## Opens the save path and writes the saved data into the file.
	file.store_var(data)
	file.close()

func load_data() -> void: ## Opens the save path. 
	if FileAccess.file_exists(save_path): ## Checks if save file exists. 
		var file = FileAccess.open(save_path, FileAccess.READ) ## Reads the save file if it exists. 
		var data = file.get_var() ## Reads the stored data. 
		file.close() ## Closes. 
		
		if typeof(data) == TYPE_DICTIONARY: ## Checks if the data loaded is a dictionary, basically a set of key value pairs so the game doesnt crash if its corrupted or missing. 
			gaze = data.get("gaze", 0) ## Looks for the key, gaze, if gaze is found it loads it, else it defaults to zero. 
	else:
		save_data() ## If the save file is empty or if the player is new to the game, instead of just crashing it creates a fresh save file. 

func _on_clickbutton_button_down() -> void: ## When the clickbutton is pressed, executes this: 
	gaze += amount_per_click ## When pressed, adds gaze by how much the variable amount_per_click is at. 
	gaze_changed.emit(gaze) ## Emits a signal to update the counter to the changed amount. 
	print(gaze)
	save_data() ## Saves. 
