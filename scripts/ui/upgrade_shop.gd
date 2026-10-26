extends VBoxContainer

@export var upgrade_button_scene: PackedScene

const UPGRADE_FOLDER := "res://scripts/data/upgrades/"

var upgrades: Array[UpgradeData] = []

@onready var upgrade_list: VBoxContainer = %UpgradeList

func _ready() -> void:
	if upgrade_button_scene == null:
		push_error("UpgradeShop has no UpgradeButton scene assigned buddy!")
		return
	
	_load_upgrades()
	
	if upgrades.is_empty():
		push_error("Upgrades array is empty in the inspector!")
		return
	
	for data in upgrades:
		if data == null:
			continue
		
		var button := upgrade_button_scene.instantiate() as UpgradeButton
		
		if button == null:
			push_error("UpgradeButton scene does not use UpgradeButton.gd")
			continue
		
		upgrade_list.add_child(button)
		button.setup(data)

func _load_upgrades() -> void:
	upgrades.clear()
	for file_name in DirAccess.get_files_at(UPGRADE_FOLDER):
		var clean_name: String = file_name.trim_suffix(".remap")
		if not clean_name.ends_with(".tres"):
			continue
		var loaded := load(UPGRADE_FOLDER + clean_name) as UpgradeData
		if loaded == null:
			push_error("Not a valid UpgradeData: %s" % clean_name)
			continue
		upgrades.append(loaded)
	upgrades.sort_custom(func(a: UpgradeData, b: UpgradeData) -> bool: return a.base_cost < b.base_cost)
	
