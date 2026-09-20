extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_parameters() -> Dictionary:
	return{
		"river_speed": $UserInputs/RiverSpeed.current_value,
		"water_amount": $UserInputs/WaterAmountPerTile.current_value,
		"groundwater_table": $UserInputs/GroundwaterTable.current_value,
		"sediment_amount": $UserInputs/SedimentVolume.current_value
	}


func _on_start_simulation_pressed() -> void:
	print("Start Simulation gedrückt")
