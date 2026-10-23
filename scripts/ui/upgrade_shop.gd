extends VBoxContainer

@export var upgrade_button_scene: PackedScene
@export var upgrades: Array[UpgradeData] = []

@onready var upgrade_list: VBoxContainer = %UpgradeList

func _ready() -> void:
	if upgrade_button_scene == null:
		push_error("UpgradeShop has no UpgradeButton scene assigned buddy!")
		return
	
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
