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
		"sediment_amount": $UserInputs/SedimentVolume.current_value,
		"min_temperature": $UserInputs/TemperatureRange.min_output,
		"max_temperature": $UserInputs/TemperatureRange.max_output,
		"min_soil_hardness": $UserInputs/SoilHardness.min_output,
		"max_soil_hardness": $UserInputs/SoilHardness.max_output,
		"min_vegetation": $UserInputs/Vegetation.min_output,
		"max_vegetation": $UserInputs/Vegetation.max_output
	}


func _on_start_simulation_pressed() -> void:
	var values := get_parameters()
	var simulation_settings := SimulationSettings.new()
	
	simulation_settings.river_speed = values["river_speed"]
	simulation_settings.water_amount = values["water_amount"]
	simulation_settings.groundwater_table = values["groundwater_table"]
	simulation_settings.sediment_amount = values ["sediment_amount"]
	simulation_settings.max_temperature = values["max_temperature"]
	simulation_settings.min_temperature = values["min_temperature"]
	simulation_settings.max_soil_hardness = values["max_soil_hardness"]
	simulation_settings.min_soil_hardness = values["min_soil_hardness"]
	simulation_settings.max_vegetation = values["max_vegetation"]
	simulation_settings.min_vegetation = values["min_vegetation"]
	
	
