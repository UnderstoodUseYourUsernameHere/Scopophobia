class_name UpgradeButton
extends Button

var data: UpgradeData

func _ready() -> void:
	pressed.connect(_on_pressed)
	GameState.gaze_changed.connect(_on_gaze_changed)

func setup(upgrade_data: UpgradeData) -> void:
	data = upgrade_data
	icon = data.icon
	tooltip_text = data.description + "\nShift-click: buy up to 10!"
	_refresh()

func _on_pressed() -> void:
	if data == null:
		return
	var count: int = 10 if Input.is_key_pressed(KEY_SHIFT) else 1
	for i in count:
		if not GameState.buy_upgrade(data):
			break

func _on_gaze_changed(
	amount: float,
	_per_second: float
) -> void:
	_refresh()

func _refresh() -> void:
	if data == null:
		return
	var amount_owned := GameState.get_owned(data.id)
	var cost := GameState.get_upgrade_cost(data)
	var effect_text := ""
	
	if data.gaze_per_second_bonus != 0.0:
		effect_text = "+%.1f gaze/sec" % data.gaze_per_second_bonus
	
	if data.gaze_per_click_bonus != 0.0:
		if not effect_text.is_empty():
			effect_text += ", "
		effect_text += "+%.1f gaze/click" % data.gaze_per_click_bonus
	
	if effect_text.is_empty():
		effect_text = "No effect configured"
	
	text = "%s - owned: %d\n%s\nCost: %s gaze" % [
		data.display_name,
		amount_owned,
		effect_text,
		GameState.format_number(cost)
	]
	
	disabled = not GameState.can_buy_upgrade(data)
