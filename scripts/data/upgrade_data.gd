class_name UpgradeData
extends Resource

@export var id: StringName
@export var display_name: String = "Upgrade"
@export_multiline var description: String = " "
@export var icon: Texture2D

@export_group("Price")
@export var base_cost: float = 10.0
@export var cost_multiplier: float = 1.15

@export_group("Effect")
@export var gaze_per_second_bonus: float = 0.0
@export var gaze_per_click_bonus: float = 0.0
