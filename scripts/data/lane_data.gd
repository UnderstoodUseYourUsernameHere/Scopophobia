class_name LaneData
extends Resource

@export var lane_name: String = "Lane"

@export_group("Placement")
@export_range(0.0, 1.0) var y_ratio: float = 0.85 ## 0.0 should be the top and 1.0 should be the bottom of the street, if i did this right.
@export_range(0.05, 2.0) var person_scale: float = 0.35
@export var z_base: int = 0

@export_group("Movement")
@export_range(10.0, 400.0) var speed: float = 90.0
@export_range(0.0, 1.0) var leftward_chance: float = 0.5 ## 0.0 is always left to right and 1 should be always right to left, and anything in between should mix them?

@export_group("Spawning")
@export_range(0.0, 10.0) var spawn_weight: float = 1.0
@export_range(0.0, 1.0) var clickable_chance: float = 0.15

@export_group("Lookie")
@export var tint: Color = Color.WHITE
