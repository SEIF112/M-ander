class_name MapPreset
extends Resource

const GENERATOR_VERSION := 1

@export var preset_name: String
@export var generator_version: int = GENERATOR_VERSION
@export var gen_settings: MapGenerationSettings
@export var sim_settings: SimulationSettings
