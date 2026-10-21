extends Control

const SAVE_PATH = "user://userdata.save" ## Saves a path for the save file.

signal gaze_changed(amount: float, per_second: float) ## Signal whenever the amount of gaze changes with the amount in an integer.

var gaze: float = 0.0 ## Amount of gaze(base currency) as a variable.
var amount_per_click: float = 1.0 ## Amount of gaze you get per click.
var gaze_per_second: float = 0 ## Placeholder for later weeks, when upgrades are added that could increase it. 


func _ready() -> void: ## Loads data and changes gaze to amount saved on game start.
	load_data()
	gaze_changed.emit(gaze, gaze_per_second)

func _on_street_person_clicked() -> void: ## When a person on street is clicked, adds gaze and emits gaze_changed. 
	gaze += amount_per_click
	gaze_changed.emit(gaze, gaze_per_second)

func save_data() -> void: ## Save function.
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE) ## Opens the save path and writes the saved data into the file.
	if file == null: ## If file is empty, pushes an error that says so, otherwise stores gaze amount and closes. 
		push_error("Could not open save file: %s" % FileAccess.get_open_error())
		return
	file.store_var({"gaze": gaze})
	file.close()

func load_data() -> void: ## Opens the save path. 
	if not FileAccess.file_exists(SAVE_PATH):
		return ## If save file doesnt exist, returns, otherwise executes following code. 
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)  ## Reads the save file if it exists. 
	if file == null: ## If the file is empty, returns, otherwise continues. 
		return
	var data = file.get_var() ## Reads the stored data. 
	file.close() ## Closes. 
	if typeof(data) == TYPE_DICTIONARY: ## Checks if loaded data is dictionary type to prevent game crashes. 
		gaze = data.get("gaze", 0) ## Looks for the key, gaze, if gaze is found it loads it, else it defaults to zero. 

func _notification(what: int) -> void: ## Saves when the X, or window close button is hit. 
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_data()
