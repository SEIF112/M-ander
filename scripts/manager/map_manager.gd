extends Node

var gen_settings := MapGenerationSettings.new()
var current_map: MapData


func create_map(sim_settings: SimulationSettings) -> MapData:
	current_map = MapGenerator.generate(gen_settings, sim_settings)
	return current_map


func delete_map() -> void:
	current_map = null
