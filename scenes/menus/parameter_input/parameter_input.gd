extends Control

var parameters = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parameters = {
		"river_speed": $Inputs/RiverSpeed.current_value
	}


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
