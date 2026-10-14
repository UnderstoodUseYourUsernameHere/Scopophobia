extends Area2D

signal target_clicked(target: Area2D)
signal target_missed(target: Area2D)

const FAR_SCALE := 0.25
const NEAR_SCALE := 1.0
const FAR_SPEED_MULT := 0.3
const NEAR_SPEED_MULT := 1.0
const FAR_TINT := Color(0.38, 0.40, 0.50)
const NEAR_TINT := Color(1, 1, 1)

@export var base_speed: float = 200.0
@export var value: int = 1

var depth: float = 1.0
var clickable: bool = false
var speed: float = 0.0
var _hovered: bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += speed * delta
	if position.x > get_viewport_rect().size.x + 100: ## Despawns if it goes off screen
		queue_free()

func _on_input_event(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		target_clicked.emit(self)
		queue_free()
