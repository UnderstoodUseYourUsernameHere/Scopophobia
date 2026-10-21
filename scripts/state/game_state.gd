extends Node

signal gaze_changed(amount: float, per_second: float)

const SAVE_PATH := "user://userdata.save"

var gaze: float = 0.0
var amount_per_click: float = 1.0
var gaze_per_second: float = 0.0
var owned_upgrades: Dictionary = {}

var _ui_update_elapsed: float = 0.0

func _ready() -> void:
	load_data()

func _process(delta: float) -> void:
	if gaze_per_second <= 0.0:
		return
	gaze += gaze_per_second * delta
	
	_ui_update_elapsed += delta
	if _ui_update_elapsed >= 0.1:
		_ui_update_elapsed = 0.0
		_emit_gaze_changed()

func click_person() -> void:
	gaze += amount_per_click
	gaze_changed.emit(gaze, gaze_per_second)

func add_gaze(amount: float) -> void:
	gaze += amount_per_click
	_emit_gaze_changed()

func get_owned(upgrade_id: StringName) -> int:
	return int(owned_upgrades.get(String(upgrade_id), 0))

func get_upgrade_cost(data: UpgradeData) -> float:
	var amount_owned := get_owned(data.id)
	return ceil(data.base_cost * pow(data.cost_multiplier, amount_owned))

func can_buy_upgrade(data: UpgradeData) -> bool:
	return gaze >= get_upgrade_cost(data)

func buy_upgrade(data: UpgradeData) -> bool:
	if data == null:
		return false
	var cost := get_upgrade_cost(data)
	
	if gaze < cost:
		return false
	gaze -= cost
	
	var key := String(data.id)
	owned_upgrades[key] = get_owned(data.id) + 1 
	
	gaze_per_second += data.gaze_per_second_bonus
	amount_per_click += data.gaze_per_click_bonus
	
	_emit_gaze_changed()
	return true

func save_data() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	
	if file == null:
		push_error("Couldnt open save file: %s" % FileAccess.get_open_error())
		return
	
	file.store_var({
		"version": 1,
		"gaze": gaze, 
		"amount_per_click": amount_per_click,
		"gaze_per_second": gaze_per_second,
		"owned_upgrades": owned_upgrades,
	})
	
	file.close()

func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	
	if file == null: 
		push_error("Could not open save file: %s" % FileAccess.get_open_error())
		return
	
	var data: Variant = file.get_var()
	file.close()
	
	if typeof(data) != TYPE_DICTIONARY:
		push_warning("Save data isnt a dictionary!")
		return
	
	gaze = float(data.get("gaze", 0.0))
	amount_per_click = float(data.get("amount_per_click", 1.0))
	gaze_per_second = float(data.get("gaze_per_second", 0.0))
	
	owned_upgrades.clear()
	
	var loaded_upgrades: Variant = data.get("owned_upgrades", {})
	if typeof(loaded_upgrades) == TYPE_DICTIONARY:
		for key in loaded_upgrades:
			owned_upgrades[String(key)] = int(loaded_upgrades[key])

func format_number(value: float) -> String:
	if value < 1_000.0:
		return "%.0f" % floor(value)
	
	if value < 1_000_000.0:
		return "%.1fK" % (value / 1_000.0)
	
	if value < 1_000_000_000.0:
		return "%.1fM" % (value / 1_000_000.0)
	
	if value < 1_000_000_000_000.0:
		return "%.1fB" % (value / 1_000_000_000.0)
	
	return "%.1fT" % (value / 1_000_000_000_000.0)

func _emit_gaze_changed() -> void:
	gaze_changed.emit(gaze, gaze_per_second)
